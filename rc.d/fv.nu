#!/usr/bin/env nu

let kube_path = "~/bin/kubectl"
let config_path = $"($env.HOME)/.config/fv"
let current_profile_path = $"($config_path)/current_profile"

let profile_re = '^FINVIA-(?P<environment>[a-zA-Z]+?)-(?P<permissions>[a-zA-Z]+?)$'

# Finvia tool: work with Finvia cloud resources.
module fv {
    # List all available Profiles
    export def "profile list" [] {
        aws configure list-profiles |
        lines |
        each {|it| profile parse $it} |
        flatten |
        compact environment permissions
    }

    # Get available profiles as names
    export def "profile names" [] {
        profile list | get name
    }

    # Get available profile environments
    def "profile envs" [] {
        profile list | get env | uniq | sort
    }

    # Parse a profile name according to profile_re
    def "profile parse" [
        name: string@"profile names", # Profile name to parse
    ] {
        let attrs = ($name | parse -r $profile_re)
        [[name]; [$name]] | merge {$attrs}
    }

    # Get the profile name associated with a particular environment and permission set.
    def "profile name-for" [
        environment: string@"profile envs", # environment to use, normally "staging" or "production"
        permissions: string = "PowerUser",  # permissions to use (default: poweruser)
    ] {
        let lower_profiles = (
            profile list |
            each { |row|
                insert env_lower ($row.environment | str downcase) |
                insert perm_lower ($row.permissions | str downcase)
            }
        );
        let maybe_name = (
            $lower_profiles |
            where env_lower == ($environment | str downcase)  && perm_lower == ($permissions | str downcase)
        );

        if ($maybe_name | length) == 0 {
            error make {
                msg: $"no profile found for environment=($environment), permissions=($permissions)"
            };
            $nothing
        } else {
            $maybe_name | first | get name
        }
    }

    # Log in to a particular profile.
    #
    # This has two effects: it logs in to AWS, and sets the Kubernetes context.
    #
    # There are two usages possible:
    #
    #  profile login <environment> (permissions)
    #
    # This will log into an appropriate profile based on the environment desired and the permission set.
    # However, it is possible that the command can fail if an appropriate matching profile cannot be found.
    #
    #  profile login --name <profile-name>
    #
    # This explicitly specifies a particular profile name, but is a bit lower level; you have to know and
    # care about the particular profile name.
    export def "profile login" [
        environment?: string@"profile envs", # environment to use, normally "staging" or "production"
        permissions: string = "PowerUser",   # permissions to use (default: poweruser)
        --name: string,                      # full profile name to use instead of environment and permissions
    ] {
        let name = if ($name != null) && ($name != "") {
            name
        } else if ($environment != null) && ($environment != "") {
            profile name-for $environment $permissions
        } else {
            error make {
                msg: "you must set either the environment or the full profile name"
            }
            $nothing
        }

        if $name != null {
            let environment = (profile parse $name | get environment | str downcase | first);

            mkdir $config_path
            echo $name | save $current_profile_path

            aws sso login --profile $name
            context set $environment
        }
    }

    # Expose what profile is currently in use.
    #
    # CAUTION: This only updates when set via this `fv` tool; it can be null or erroneous.
    export def "profile current" [] {
        if ($current_profile_path | path exists) {
            profile parse (open $current_profile_path --raw)
        } else {
            $nothing
        }
    }

    # Expose what Kubernetes context is currently in use.
    export def "context current" [] {
        let context_name = (^$kube_path config current-context | str trim)
        context get $context_name
    }

    # List all available Kubernetes contexts.
    export def "context list" [] {
        [
            {
                name: finvia-staging-cluster
                environment: staging
                cluster: (cluster get staging)
            }
            {
                name: finvia-production-cluster
                environment: production
                cluster: (cluster get production)
            }
        ]
    }

    # List all available Kubernetes context names.
    def "context names" [] {
        context list | get name
    }

    # List all available Kubernetes context environments.
    def "context envs" [] {
        context list | get environment
    }

    # Get a particular kubernetes context by name.
    def "context get" [name: string@"context names"] {
        context list | where name == ($name | str downcase) | first
    }

    # Update the current kubernetes context.
    def "context set" [
        environment: string@"context envs",
    ] {
        let context_name = (context list | where environment == ($environment | str downcase) | get name | first)
        ^$kube_path config use-context $context_name
    }

    # List all known clusters.
    export def "cluster list" [] {
        [
            {
                name: staging
                aws_account_id: 225254349069
                db: {
                    host: "terraform-20210615111248889200000002.c4mc45uolaov.eu-central-1.rds.amazonaws.com"
                    port: 5432
                }
                services: [
                    {
                        name: profile
                        namespace: sq-access
                        db: {
                            name: profile_service
                            user: postgres
                            secret_name: profile-service
                        }
                    }
                    {
                        name: identification
                        namespace: sq-access
                        db: {
                            name: identification
                            user: postgres
                            secret_name: identification-service
                        }
                    }
                    {
                        name: documents
                        namespace: sq-insights
                        db: {
                            name: document_service
                            user: postgres
                            secret_name: document-service
                        }
                    }
                    {
                        name: bastion
                        namespace: sq-platform
                        label: "app.kubernetes.io/name=bastion-host"
                    }
                ]
                profiles: [
                    {
                        name: "default"
                        email: "m.duenbostell@finvia.fo"
                        owner_id: "66df4b82-034a-444a-b3b3-ee6c7c6554f8"
                        person_id: "2cf381bf-526b-4e93-bfc8-19ca8631d8cf"
                        legal_entity_id: "5bcaa3e4-7d50-42ee-a633-dd727f9fcbf1"
                    }
                    {
                        name: "imported"
                        email: "m.duenbostell+imported@finvia.fo"
                        owner_id: "04d85dff-488e-4ae2-b6a0-9da08e11e3bc"
                        person_id: $nothing
                        legal_entity_id: $nothing
                    }
                ]
            }
            {
                name: production
                aws_account_id: 936127192905
                db: {
                    host: "terraform-20210616125503990200000005.cu5sero3fbk1.eu-central-1.rds.amazonaws.com"
                    port: 5432
                }
                services: [
                    {
                        name: profile
                        namespace: flux-system
                        db: {
                            name: profile_service
                            user: postgres
                            secret_name: profile-service
                        }
                    }
                    {
                        name: identification
                        namespace: flux-system
                        db: {
                            name: identification
                            user: postgres
                            secret_name: identification-service
                        }
                    }
                    {
                        name: documents
                        namespace: flux-system
                        db: {
                            name: document_service
                            user: postgres
                            secret_name: document-service
                        }
                    }
                    {
                        name: bastion
                        namespace: flux-system
                        label: "app.kubernetes.io/name=bastion-host"
                    }
                ]
                me: {
                    owner_id: "unknown"
                    person_id: "unknown"
                }
            }
        ]
    }

    # Show which cluster is currently active.
    export def "cluster current" [] {
        context current | get cluster
    }

    # List of cluster environments.
    def "cluster envs" [] {
        cluster list | get name
    }

    # Get a particular cluster by name.
    export def "cluster get" [cluster_name: string@"cluster envs"] {
        cluster list | where name == $cluster_name | first
    }

    def "service list" [] {
        cluster current | get services
    }

    def "service names" [] {
        service list | get name
    }

    export def "service get" [$service_name: string@"service names"] {
        let cluster = cluster current
        let service = (service list | where name == $service_name | first)
        let service = ($service | default {} db)
        # Merging is reversed:
        # https://github.com/nushell/nushell/issues/5282
        let db = ($service.db | merge { $cluster.db })

        $service | update db $db
    }

    export def "bastion pod" [] {
        let bastion = (service get bastion)

        ^$kube_path get pod -n $bastion.namespace -l $bastion.label -o name
        | str trim
        | str replace "^pod/" ""
    }

    export def "bastion exec" [
        command: string
        ...args: string
    ] {
        let bastion = service get bastion

        (run-external $"($env.HOME)/bin/kubectl" exec "-n" $bastion.namespace "-it" (bastion pod) "--" $command $args)
    }

    export def "bastion pull" [
        source: string
        target: string
    ] {
        let bastion = (service get bastion)

        ^$kube_path cp -n $bastion.namespace $"(bastion pod):($source)" $target
    }

    export def "bastion push" [
        source: string
        target: string
    ] {
        let bastion = (service get bastion)

        ^$kube_path cp -n $bastion.namespace $source $"(bastion pod):($target)"
    }

    export def "bastion shell" [] {
        bastion exec bash
    }

    export def "bastion db" [
        service_name: string@"service names"
    ] {
        bastion exec "psql" "--pset=pager=off" "--pset=format=wrapped" "--expanded" (db connection-string $service_name)
    }

    export def "db current" [] {
        cluster current | get db
    }

    # Prerequisites:
    # > aws --profile PROFILE sso login
    # > kubectl config use-context CONTEXT
    export def "db dump" [
        service_name: string@"service names"
    ] {
        let cluster = cluster current
        let service = service get $service_name
        let bastion = service get bastion
        let db = $service.db
        let db_secret = (^$kube_path get secret $db.secret_name -o "go-template={{ .data.dbPassword }}" -n flux-system | ^base64 --decode)

        let bastion_host_pod = bastion pod

        # let dump_name = $"($service_name)-($cluster.name)-(random uuid).pgdump"
        let dump_name = $"($service_name)-($cluster.name)-(date now | date format '%Y-%m-%d-%H-%M-%S').pgdump"
        let dump_command = $"PGPASSWORD='($db_secret)' pg_dump -Fc -h '($db.host)' -p '($db.port)' -U postgres -d '($db.name)' > '/tmp/($dump_name)'"

        echo $">>> Starting dump [($dump_name)]"
        ^$kube_path exec -n $bastion.namespace $bastion_host_pod -- sh -c $dump_command
        echo

        echo $">>> Fetching dump [($dump_name)]"
        ^$kube_path cp -n $bastion.namespace $"($bastion_host_pod):/tmp/($dump_name)" $dump_name
        echo

        echo ">>> Cleanup"
        ^$kube_path exec -n $bastion.namespace $bastion_host_pod -- rm $"/tmp/($dump_name)"
    }

    export def "db secret" [
        service_name: string@"service names"
    ] {
        let service = service get $service_name

        (^$kube_path get secret $service.db.secret_name -o "go-template={{ .data.dbPassword }}" -n flux-system | ^base64 --decode)
    }

    export def "db connection-string" [
        service_name: string@"service names"
    ] {
        let service = service get $service_name
        let db = $service.db
        let secret = db secret $service_name

        $"postgres://($db.user):($secret)@($db.host)/($db.name)"
    }
}

use fv
