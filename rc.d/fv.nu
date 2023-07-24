#!/usr/bin/env nu

# known working nu version:
# (0.82.0)

export def "context current" [] {
    let context_name = (^kubectl config current-context | str trim)

    context get $context_name
}

export def "context list" [] {
    [
        {
            name: finvia-staging-cluster
            cluster: (cluster get staging)
        }
        {
            name: finvia-production-cluster
            cluster: (cluster get production)
        }
    ]
}

export def "context names" [] {
    context list | get name
}

export def "context get" [cluster_name: string@"context names"] {
    context list | where name == $cluster_name | first
}

export def "context envs" [] {
    context list | get cluster.name
}

export def "context get-env" [environment: string@"context envs"] {
    context list | where cluster.name == $environment | first
}

export def "context set" [environment: string@"context envs"] {
    ^kubectl config use-context (context get-env $environment | get name)
}

export def "cluster list" [] {
    [
        {
            name: staging
            aws_profile: "FINVIA-Staging-PowerUser"
            aws_account_id: "225254349069"
            cognito: {
                aws_profile: "mfa"
                user_pool: "eu-central-1_2pm7wovFD"
            }
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
            aws_profile: "FINVIA-Production-PowerUser"
            aws_account_id: "936127192905"
            cognito: {
                aws_profile: "FINVIA-CognitoProd-ReadOnly"
                user_pool: "eu-central-1_jMPzWliAQ"
            }
            db: {
                host: "terraform-20210616125503990200000005.cu5sero3fbk1.eu-central-1.rds.amazonaws.com"
                port: 5432
            }
            services: [
                {
                    name: profile
                    namespace: sq-access
                    db: {
                        name: profile_service
                        user: sq_access__profile
                        secret_name: profile-service
                        defines_db_url: true
                        defines_db_password: false
                    }
                }
                {
                    name: identification
                    namespace: sq-access
                    db: {
                        name: identification
                        user: sq_access__identification
                        secret_name: identification-service
                        defines_db_url: false
                        defines_db_password: true
                    }
                }
                {
                    name: documents
                    namespace: sq-insights
                    db: {
                        name: document_service
                        user: sq_insights__documents
                        secret_name: document-service
                        defines_db_url: true
                        defines_db_password: false
                    }
                }
                {
                    name: bastion
                    namespace: sq-platform
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

export def "cluster current" [] {
    context current | get cluster
}

export def "cluster names" [] {
    cluster list | get name
}

export def "cluster get" [cluster_name: string@"cluster names"] {
    cluster list | where name == $cluster_name | first
}

export def "cluster login" [environment?: string@"context envs"] {
    let profile = if ($environment == null) {
        (context current).cluster.aws_profile
    } else {
        (cluster get $environment).aws_profile
    }

    ^aws --profile $profile sso login
    if ($environment != null) {
        context set $environment
    }
    ecr login
}

export def "ecr login" [] {
    ^aws ecr get-login-password --profile FINVIA-ECR-ReadOnly | ^docker login --username AWS --password-stdin 533806089962.dkr.ecr.eu-central-1.amazonaws.com
}

export def "service list" [] {
    cluster current | get services
}

export def "service names" [] {
    service list | get name
}

export def "service get" [$service_name: string@"service names"] {
    let cluster = (cluster current)
    let service = (service list | where name == $service_name | first)
    let service = ($service | default {} db)
    # Merging is reversed:
    # https://github.com/nushell/nushell/issues/5282
    let db = ($cluster.db | merge $service.db)

    $service | update db $db
}

export def "bastion pod" [] {
    let bastion = (service get bastion)
    ^kubectl get pod -n $bastion.namespace -l $bastion.label -o name
    | str trim
    | str replace "^pod/" ""
}

export def "bastion exec" [
    --redirect-stdout
    command: string
    ...args: string
] {
    let stdin = $in;
    let bastion = (service get bastion)

    if ($redirect_stdout) {
        ($stdin | run-external --redirect-stdout kubectl exec "-n" $bastion.namespace "-it" (bastion pod) "--" $command $args)
    } else {
        ($stdin | run-external kubectl exec "-n" $bastion.namespace "-it" (bastion pod) "--" $command $args)
    }
}

export def "bastion pull" [
    source: string
    target: string
] {
    let bastion = (service get bastion)

    ^kubectl cp -n $bastion.namespace $"(bastion pod):($source)" $target
}

export def "bastion push" [
    source: string
    target: string
] {
    let bastion = (service get bastion)

    ^kubectl cp -n $bastion.namespace $source $"(bastion pod):($target)"
}

export def "bastion shell" [] {
    bastion exec bash
}

export def "bastion db" [
    service_name: string@"service names"
] {
    bastion exec "psql" "--pset=pager=off" "--pset=format=wrapped" "--expanded" (db connection-string $service_name)
}

export def "bastion db csv" [
    service_name: string@"service names"
    query: string
] {
    ($in | bastion exec
            --redirect-stdout
            "psql"
            "--pset=pager=off"
            "--csv"
            "--field-separator=,"
            "--command" $query
            (db connection-string $service_name)
    )
}

export def "bastion db query" [
    service_name: string@"service names"
    query: string
] {
    let stdin = $in
    let stdin = (if $stdin != $nothing { $stdin | to csv } else { $stdin })

    $stdin | bastion db csv $service_name $query | from csv --no-infer
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
    let cluster = (cluster current)
    let service = (service get $service_name)
    let bastion = (service get bastion)
    let db = $service.db
    let db_secret = (db secret $service_name)

    let bastion_host_pod = (bastion pod)

    # let dump_name = $"($service_name)-($cluster.name)-(random uuid).pgdump"
    let dump_name = $"($service_name)-($cluster.name)-(date now | date format '%Y-%m-%d-%H-%M-%S').pgdump"
    let dump_command = $"PGPASSWORD='($db_secret)' pg_dump -Fc -h '($db.host)' -p '($db.port)' -U postgres -d '($db.name)' > '/tmp/($dump_name)'"

    echo $">>> Starting dump [($dump_name)]"
    ^kubectl exec -n $bastion.namespace $bastion_host_pod -- sh -c $dump_command
    echo

    echo $">>> Fetching dump [($dump_name)]"
    ^kubectl cp -n $bastion.namespace $"($bastion_host_pod):/tmp/($dump_name)" $dump_name
    echo

    echo ">>> Cleanup"
    ^kubectl exec -n $bastion.namespace $bastion_host_pod -- rm $"/tmp/($dump_name)"
}

export def "db secret" [
    service_name: string@"service names"
] {
    let service = (service get $service_name)

    if $service.db.defines_db_password {
        (^kubectl get secret $service.db.secret_name -n $service.namespace -o 'jsonpath={.data.dbPassword}' | ^base64 --decode)
    } else if $service.db.defines_db_url {
        (db connection-string $service_name | url parse | get password)
    } else {
        let span = (metadata $service_name).span

        error make {
            msg: "service does not define a mechanism for retrieving the database secret",
            start: $span.start,
            end: $span.end,
        }
    }

}

export def "db connection-string" [
    service_name: string@"service names"
] {
    let service = (service get $service_name)

    if $service.db.defines_db_url {
        (^kubectl get secret $service.db.secret_name -n $service.namespace -o "go-template={{ .data.dbUrl }}" | ^base64 --decode)
    } else if $service.db.defines_db_password {
        let user = $service.db.user
        let secret = (db secret $service_name)
        let host = $service.db.host
        let name = $service.db.name

        $"postgres://($user):($secret)@($host)/($name)"
    } else {
        let span = (metadata $service_name).span

        error make {
            msg: "service does not define a mechanism for retrieving the database secret",
            start: $span.start,
            end: $span.end,
        }
    }
}

export def "cognito users" [] {
    let cognito = (cluster current | get cognito)
    ^aws --output json cognito-idp list-users --user-pool-id $cognito.user_pool --profile $cognito.aws_profile --region eu-central-1 | from json | get Users
}

export def "cognito groups" [] {
    let cognito = (cluster current | get cognito)
    ^aws --output json cognito-idp list-groups --user-pool-id $cognito.user_pool --profile $cognito.aws_profile --region eu-central-1 | from json | get Groups
}

export def "cognito users-in-group" [
    group: string
] {
    let cognito = (cluster current | get cognito)
    ^aws --output json cognito-idp list-users-in-group --user-pool-id $cognito.user_pool --profile $cognito.aws_profile --region eu-central-1 --group $group | from json | get Users
}

export def "login" [environment?: string@"context envs"] {
    cluster login $environment
}

# ╭────────╮
# │  main  │
# ╰────────╯

def main [] {
    help main
}

# Log-in to AWS
def "main login" [environment?: string@"context envs"] {
    login $environment
}

# Get a psql session on the bastion host to the db of `service`
def "main psql" [
    service: string@"service names" # profile, identification, documents, …
] {
    bastion db $service
}

# Dump the database of `service`
def "main dump" [
    service: string@"service names" # profile, identification, documents, …
] {
    db dump $service
}

# Get a shell on the bastion host
def "main bastion shell" [] {
    bastion shell
}

# Pull file or directory from the bastion host
export def "main bastion pull" [
    source: string # remote path
    target: string # local path
] {
    bastion pull $source $target
}

# Push a file or directory to the bastion host
export def "main bastion push" [
    source: string # local path
    target: string # remote path
] {
    bastion push $source $target
}
