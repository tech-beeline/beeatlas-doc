workspace {
    name "TST"
    description "Some generic system"

    # версия проекта архитектуры
    properties {
        "version" "1.0"
    }
    
    # включаем режим с иерархической системой идентификаторов
    # !impliedRelationships false
    !identifiers hierarchical

    # Папка с ADR
    # !adrs adrs

    # Пака с документацией
    # !docs docs

    model {
        properties { 
            # Настраиваем возможность создания вложенных груп
            structurizr.groupSeparator "/"
            
            # устанавливаем код приложения для идентификации на дашборде производственного процесса
            workspace_cmdb "TST"
            cmdb "TST"
            
            # указываем имя ответственного архитектора
            architect "Яскевич Никита Андреевич NAYaskevich@beeline.ru"

            # путь к документации в Confluence
            documentation "https://bwiki.beeline.ru/"
        }

        IDP = softwareSystem "IDP" {
            tags "landscape"
            properties {
                "cmdb" "IDP"
            }
        }

        MOBILEAPP = softwareSystem "Mobile APP" {
            tags "landscape"
            properties {
                "cmdb" "MOBILEAPP"
            }
        }

        MAPIC = softwareSystem "MAPIC" {
            tags "landscape"
            properties {
                "cmdb" "MAPIC"
            }
        }

        BEELINE_CLOUD = softwareSystem "Datafort Beeline Cloud" {
            tags "external"
        }

        NEWSYS = softwareSystem "NEW PLANNED PRODUCT" {
            tags "tbd"
        }

        LEGSYS = softwareSystem "LEGACY PRODUCT" {
            tags "legacy"
        }

        TST = softwareSystem "TST Beeline Internal System" {
            properties {
                "status" "В эксплуатации"
                "domain" "Блок по работе с данными"
                "author" "Яскевич Никита Андреевич <NAYaskevich@beeline.ru>"
            }
        }

        group "users" {
            person_admin = person "Администратор"
            person_support = person "Специалист ТП"
        }

        person_user = person "Абонент" {
          tags "external"
        }

        person_admin -> TST "Администрирует"
        person_support -> TST "Обслуживает"
        person_user -> MOBILEAPP "Использует"

        MOBILEAPP -> MAPIC "Запросы абонентов"
        MAPIC -> TST "Проксирование запросов абонентов"
        TST -> IDP "Аутентификация пользователей"
        TST -> BEELINE_CLOUD "Запуск задач в публичном контуре"
        NEWSYS -> TST "Использует данные" { 
          tags "Relationship, tbdrel" 
        }
        LEGSYS -> TST "Использует данные"

        !element TST {

            fw_grp = group "Технорадар - Фреймворки и инструменты" {

              TST_container_fw_angular = container "appliance of angular" {
              description "Instance of application runs on angular "
              tags "angular"
              }
              TST_container_fw_archi = container "appliance of archi" {
              description "Instance of application runs on archi "
              tags "archi"
              }
              TST_container_fw_asimus = container "appliance of asimus" {
              description "Instance of application runs on asimus "
              tags "asimus"
              }
              TST_container_fw_aspnet = container "appliance of aspnet" {
              description "Instance of application runs on aspnet "
              tags "aspnet"
              }
              TST_container_fw_chaosmonkey = container "appliance of chaosmonkey" {
              description "Instance of application runs on chaosmonkey "
              tags "chaosmonkey"
              }
              TST_container_fw_confluence = container "appliance of confluence" {
              description "Instance of application runs on confluence "
              tags "confluence"
              }
              TST_container_fw_devexpress = container "appliance of devexpress" {
              description "Instance of application runs on devexpress "
              tags "devexpress"
              }
              TST_container_fw_directus = container "appliance of directus" {
              description "Instance of application runs on directus "
              tags "directus"
              }
              TST_container_fw_dotnet = container "appliance of dotnet" {
              description "Instance of application runs on dotnet "
              tags "dotnet"
              }
              TST_container_fw_drawio = container "appliance of drawio" {
              description "Instance of application runs on drawio "
              tags "drawio"
              }
              TST_container_fw_element = container "appliance of element" {
              description "Instance of application runs on element "
              tags "element"
              }
              TST_container_fw_eleventy = container "appliance of eleventy" {
              description "Instance of application runs on eleventy "
              tags "eleventy"
              }
              TST_container_fw_excalidraw = container "appliance of excalidraw" {
              description "Instance of application runs on excalidraw "
              tags "excalidraw"
              }
              TST_container_fw_express = container "appliance of express" {
              description "Instance of application runs on express "
              tags "express"
              }
              TST_container_fw_figma = container "appliance of figma" {
              description "Instance of application runs on figma "
              tags "figma"
              }
              TST_container_fw_gatsbyjs = container "appliance of gatsbyjs" {
              description "Instance of application runs on gatsbyjs "
              tags "gatsbyjs"
              }
              TST_container_fw_java_server_pages = container "appliance of java_server_pages" {
              description "Instance of application runs on java_server_pages "
              tags "java_server_pages"
              }
              TST_container_fw_jest = container "appliance of jest" {
              description "Instance of application runs on jest "
              tags "jest"
              }
              TST_container_fw_jinja = container "appliance of jinja" {
              description "Instance of application runs on jinja "
              tags "jinja"
              }
              TST_container_fw_jira = container "appliance of jira" {
              description "Instance of application runs on jira "
              tags "jira"
              }
              TST_container_fw_loadui = container "appliance of loadui" {
              description "Instance of application runs on loadui "
              tags "loadui"
              }
              TST_container_fw_matomo = container "appliance of matomo" {
              description "Instance of application runs on matomo "
              tags "matomo"
              }
              TST_container_fw_maze = container "appliance of maze" {
              description "Instance of application runs on maze "
              tags "maze"
              }
              TST_container_fw_miro = container "appliance of miro" {
              description "Instance of application runs on miro "
              tags "miro"
              }
              TST_container_fw_nextjs = container "appliance of nextjs" {
              description "Instance of application runs on nextjs "
              tags "nextjs"
              }
              TST_container_fw_nodejs = container "appliance of nodejs" {
              description "Instance of application runs on nodejs "
              tags "nodejs"
              }
              TST_container_fw_pixso = container "appliance of pixso" {
              description "Instance of application runs on pixso "
              tags "pixso"
              }
              TST_container_fw_plantuml = container "appliance of plantuml" {
              description "Instance of application runs on plantuml "
              tags "plantuml"
              }
              TST_container_fw_react = container "appliance of react" {
              description "Instance of application runs on react "
              tags "react"
              }
              TST_container_fw_react_native = container "appliance of react_native" {
              description "Instance of application runs on react_native "
              tags "react_native"
              }
              TST_container_fw_remix = container "appliance of remix" {
              description "Instance of application runs on remix "
              tags "remix"
              }
              TST_container_fw_slack = container "appliance of slack" {
              description "Instance of application runs on slack "
              tags "slack"
              }
              TST_container_fw_soapui = container "appliance of soapui" {
              description "Instance of application runs on soapui "
              tags "soapui"
              }
              TST_container_fw_sparxea = container "appliance of sparxea" {
              description "Instance of application runs on sparxea "
              tags "sparxea"
              }
              TST_container_fw_spring = container "appliance of spring" {
              description "Instance of application runs on spring "
              tags "spring"
              }
              TST_container_fw_springboot = container "appliance of springboot" {
              description "Instance of application runs on springboot "
              tags "springboot"
              }
              TST_container_fw_structurizr_lite = container "appliance of structurizr_lite" {
              description "Instance of application runs on structurizr_lite "
              tags "structurizr_lite"
              }
              TST_container_fw_structurizr_onprem = container "appliance of structurizr_onprem" {
              description "Instance of application runs on structurizr_onprem "
              tags "structurizr_onprem"
              }
              TST_container_fw_swagger = container "appliance of swagger" {
              description "Instance of application runs on swagger "
              tags "swagger"
              }
              TST_container_fw_temporal = container "appliance of temporal" {
              description "Instance of application runs on temporal "
              tags "temporal"
              }
              TST_container_fw_tibco_bw = container "appliance of tibco_bw" {
              description "Instance of application runs on tibco_bw "
              tags "tibco_bw"
              }
              TST_container_fw_tibco_ems = container "appliance of tibco_ems" {
              description "Instance of application runs on tibco_ems "
              tags "tibco_ems"
              }
              TST_container_fw_tibco_iprocess = container "appliance of tibco_iprocess" {
              description "Instance of application runs on tibco_iprocess "
              tags "tibco_iprocess"
              }
              TST_container_fw_time = container "appliance of time" {
              description "Instance of application runs on time "
              tags "time"
              }
              TST_container_fw_vector = container "appliance of vector" {
              description "Instance of application runs on vector "
              tags "vector"
              }
              TST_container_fw_vue = container "appliance of vue" {
              description "Instance of application runs on vue "
              tags "vue"
              }
              TST_container_fw_webpack = container "appliance of webpack" {
              description "Instance of application runs on webpack "
              tags "webpack"
              }
              TST_container_fw_xunit = container "appliance of xunit" {
              description "Instance of application runs on xunit "
              tags "xunit"
              }
              TST_container_fw_yandex_metrica = container "appliance of yandex_metrica" {
              description "Instance of application runs on yandex_metrica "
              tags "yandex_metrica"
              }
              TST_container_fw_zephyr = container "appliance of zephyr" {
              description "Instance of application runs on zephyr "
              tags "zephyr"
              }

            }

            infr_grp = group "Технорадар - платформа и инфраструктура" {

              TST_container_infr_ttms = container "appliance of ttms" {
              description "Instance of application runs on ttms "
              tags "ttms"
              }
              TST_container_infr_alma = container "appliance of alma" {
              description "Instance of application runs on alma "
              tags "alma"
              }
              TST_container_infr_alpine = container "appliance of alpine" {
              description "Instance of application runs on alpine "
              tags "alpine"
              }
              TST_container_infr_alteon = container "appliance of alteon" {
              description "Instance of application runs on alteon "
              tags "alteon"
              }
              TST_container_infr_ansible = container "appliance of ansible" {
              description "Instance of application runs on ansible "
              tags "ansible"
              }
              TST_container_infr_apache = container "appliance of apache" {
              description "Instance of application runs on apache "
              tags "apache"
              }
              TST_container_infr_argocd = container "appliance of argocd" {
              description "Instance of application runs on argocd "
              tags "argocd"
              }
              TST_container_infr_avast = container "appliance of avast" {
              description "Instance of application runs on avast "
              tags "avast"
              }
              TST_container_infr_caddy = container "appliance of caddy" {
              description "Instance of application runs on caddy "
              tags "caddy"
              }
              TST_container_infr_camunda = container "appliance of camunda" {
              description "Instance of application runs on camunda "
              tags "camunda"
              }
              TST_container_infr_centos = container "appliance of centos" {
              description "Instance of application runs on centos "
              tags "centos"
              }
              TST_container_infr_cisco_firewall = container "appliance of cisco_firewall" {
              description "Instance of application runs on cisco_firewall "
              tags "cisco_firewall"
              }
              TST_container_infr_codescoring = container "appliance of codescoring" {
              description "Instance of application runs on codescoring "
              tags "codescoring"
              }
              TST_container_infr_consul = container "appliance of consul" {
              description "Instance of application runs on consul "
              tags "consul"
              }
              TST_container_infr_debian = container "appliance of debian" {
              description "Instance of application runs on debian "
              tags "debian"
              }
              TST_container_infr_docker = container "appliance of docker" {
              description "Instance of application runs on docker "
              tags "docker"
              }
              TST_container_infr_elastic = container "appliance of elastic" {
              description "Instance of application runs on elastic "
              tags "elastic"
              }
              TST_container_infr_freertos = container "appliance of freertos" {
              description "Instance of application runs on freertos "
              tags "freertos"
              }
              TST_container_infr_gitlab_ce = container "appliance of gitlab_ce" {
              description "Instance of application runs on gitlab_ce "
              tags "gitlab_ce"
              }
              TST_container_infr_gitlab_ee = container "appliance of gitlab_ee" {
              description "Instance of application runs on gitlab_ee "
              tags "gitlab_ee"
              }
              TST_container_infr_glassfish = container "appliance of glassfish" {
              description "Instance of application runs on glassfish "
              tags "glassfish"
              }
              TST_container_infr_grafana = container "appliance of grafana" {
              description "Instance of application runs on grafana "
              tags "grafana"
              }
              TST_container_infr_haproxy = container "appliance of haproxy" {
              description "Instance of application runs on haproxy "
              tags "haproxy"
              }
              TST_container_infr_harbor = container "appliance of harbor" {
              description "Instance of application runs on harbor "
              tags "harbor"
              }
              TST_container_infr_helm = container "appliance of helm" {
              description "Instance of application runs on helm "
              tags "helm"
              }
              TST_container_infr_hyperv = container "appliance of hyperv" {
              description "Instance of application runs on hyperv "
              tags "hyperv"
              }
              TST_container_infr_iis = container "appliance of iis" {
              description "Instance of application runs on iis "
              tags "iis"
              }
              TST_container_infr_istio = container "appliance of istio" {
              description "Instance of application runs on istio "
              tags "istio"
              }
              TST_container_infr_jaeger = container "appliance of jaeger" {
              description "Instance of application runs on jaeger "
              tags "jaeger"
              }
              TST_container_infr_jenkins = container "appliance of jenkins" {
              description "Instance of application runs on jenkins "
              tags "jenkins"
              }
              TST_container_infr_k8s = container "appliance of kubernetes" {
              description "Instance of application runs on kubernetes "
              tags "kubernetes"
              }
              TST_container_infr_kaspersky = container "appliance of kaspersky" {
              description "Instance of application runs on kaspersky "
              tags "kaspersky"
              }
              TST_container_infr_keda = container "appliance of keda" {
              description "Instance of application runs on keda "
              tags "keda"
              }
              TST_container_infr_keycloak = container "appliance of keycloak" {
              description "Instance of application runs on keycloak "
              tags "keycloak"
              }
              TST_container_infr_linux = container "appliance of linux" {
              description "Instance of application runs on linux "
              tags "linux"
              }
              TST_container_infr_lxc = container "appliance of lxc" {
              description "Instance of application runs on lxc "
              tags "lxc"
              }
              TST_container_infr_mcafee = container "appliance of mcafee" {
              description "Instance of application runs on mcafee "
              tags "mcafee"
              }
              TST_container_infr_mdm_apple = container "appliance of mdm_apple" {
              description "Instance of application runs on mdm_apple "
              tags "mdm_apple"
              }
              TST_container_infr_ms_ad = container "appliance of ms_ad" {
              description "Instance of application runs on ms_ad "
              tags "ms_ad"
              }
              TST_container_infr_ms_exchange = container "appliance of ms_exchange" {
              description "Instance of application runs on ms_exchange "
              tags "ms_exchange"
              }
              TST_container_infr_ms_scom = container "appliance of ms_scom" {
              description "Instance of application runs on ms_scom "
              tags "ms_scom"
              }
              TST_container_infr_n8n = container "appliance of n8n" {
              description "Instance of application runs on n8n "
              tags "n8n"
              }
              TST_container_infr_nexus = container "appliance of nexus" {
              description "Instance of application runs on nexus "
              tags "nexus"
              }
              TST_container_infr_nginx = container "appliance of nginx" {
              description "Instance of application runs on nginx "
              tags "nginx"
              }
              TST_container_infr_bmcnsm = container "appliance of bmcnsm" {
              description "Instance of application runs on bmcnsm "
              tags "bmcnsm"
              }
              TST_container_infr_octopus_deploy = container "appliance of octopus_deploy" {
              description "Instance of application runs on octopus_deploy "
              tags "octopus_deploy"
              }
              TST_container_infr_openstack = container "appliance of openstack" {
              description "Instance of application runs on openstack "
              tags "openstack"
              }
              TST_container_infr_oralinux = container "appliance of oralinux" {
              description "Instance of application runs on oralinux "
              tags "oralinux"
              }
              TST_container_infr_prometheus = container "appliance of prometheus" {
              description "Instance of application runs on prometheus "
              tags "prometheus"
              }
              TST_container_infr_remedy = container "appliance of remedy" {
              description "Instance of application runs on remedy "
              tags "remedy"
              }
              TST_container_infr_rhel = container "appliance of rhel" {
              description "Instance of application runs on rhel "
              tags "rhel"
              }
              TST_container_infr_rocky = container "appliance of rocky" {
              description "Instance of application runs on rocky "
              tags "rocky"
              }
              TST_container_infr_samba = container "appliance of samba" {
              description "Instance of application runs on samba "
              tags "samba"
              }
              TST_container_infr_sccm = container "appliance of sccm" {
              description "Instance of application runs on sccm "
              tags "sccm"
              }
              TST_container_infr_sentry = container "appliance of sentry" {
              description "Instance of application runs on sentry "
              tags "sentry"
              }
              TST_container_infr_sfera = container "appliance of sfera" {
              description "Instance of application runs on sfera "
              tags "sfera"
              }
              TST_container_infr_solar_appscreener = container "appliance of solar_appscreener" {
              description "Instance of application runs on solar_appscreener "
              tags "solar_appscreener"
              }
              TST_container_infr_solaris = container "appliance of solaris" {
              description "Instance of application runs on solaris "
              tags "solaris"
              }
              TST_container_infr_sonarqube = container "appliance of sonarqube" {
              description "Instance of application runs on sonarqube "
              tags "sonarqube"
              }
              TST_container_infr_tcsh = container "appliance of tcsh" {
              description "Instance of application runs on tcsh "
              tags "tcsh"
              }
              TST_container_infr_teamcity = container "appliance of teamcity" {
              description "Instance of application runs on teamcity "
              tags "teamcity"
              }
              TST_container_infr_terraform = container "appliance of terraform" {
              description "Instance of application runs on terraform "
              tags "terraform"
              }
              TST_container_infr_tomcat = container "appliance of tomcat" {
              description "Instance of application runs on tomcat "
              tags "tomcat"
              }
              TST_container_infr_tuxedoserver = container "appliance of tuxedoserver" {
              description "Instance of application runs on tuxedoserver "
              tags "tuxedoserver"
              }
              TST_container_infr_ubuntu = container "appliance of ubuntu" {
              description "Instance of application runs on ubuntu "
              tags "ubuntu"
              }
              TST_container_infr_vault = container "appliance of vault" {
              description "Instance of application runs on vault "
              tags "vault"
              }
              TST_container_infr_veritas_netbackup = container "appliance of veritas_netbackup" {
              description "Instance of application runs on veritas_netbackup "
              tags "veritas_netbackup"
              }
              TST_container_infr_veritasclusterserver = container "appliance of vcs" {
              description "Instance of application runs on vcs "
              tags "vcs"
              }
              TST_container_infr_vsphere = container "appliance of vsphere" {
              description "Instance of application runs on vsphere "
              tags "vsphere"
              }
              TST_container_infr_windows = container "appliance of windows" {
              description "Instance of application runs on windows "
              tags "windows"
              }
              TST_container_infr_windows_server_2016 = container "appliance of windows_server_2016" {
              description "Instance of application runs on windows_server_2016 "
              tags "windows_server_2016"
              }
              TST_container_infr_zabbix = container "appliance of zabbix" {
              description "Instance of application runs on zabbix "
              tags "zabbix"
              }


            }

            dm_grp = group "Технорадар - Управление данными"  {
    
              TST_container_dm_activemq = container "appliance of activemq" {
              description "Instance of application runs on activemq "
              tags "activemq"
              }
              TST_container_dm_airflow = container "appliance of airflow" {
              description "Instance of application runs on airflow "
              tags "airflow"
              }
              TST_container_dm_amqp = container "appliance of amqp" {
              description "Instance of application runs on amqp "
              tags "amqp"
              }
              TST_container_dm_apachecamel = container "appliance of apachecamel" {
              description "Instance of application runs on apachecamel "
              tags "apachecamel"
              }
              TST_container_dm_cassandra = container "appliance of cassandra" {
              description "Instance of application runs on cassandra "
              tags "cassandra"
              }
              TST_container_dm_ceph = container "appliance of ceph" {
              description "Instance of application runs on ceph "
              tags "ceph"
              }
              TST_container_dm_clickhouse = container "appliance of clickhouse" {
              description "Instance of application runs on clickhouse "
              tags "clickhouse"
              }
              TST_container_dm_dolphinscheduler = container "appliance of dolphinscheduler" {
              description "Instance of application runs on dolphinscheduler "
              tags "dolphinscheduler"
              }
              TST_container_dm_doris = container "appliance of doris" {
              description "Instance of application runs on doris "
              tags "doris"
              }
              TST_container_dm_flink = container "appliance of flink" {
              description "Instance of application runs on flink "
              tags "flink"
              }
              TST_container_dm_ftp = container "appliance of ftp" {
              description "Instance of application runs on ftp "
              tags "ftp"
              }
              TST_container_dm_greenplum = container "appliance of greenplum" {
              description "Instance of application runs on greenplum "
              tags "greenplum"
              }
              TST_container_dm_grpc = container "appliance of grpc" {
              description "Instance of application runs on grpc "
              tags "grpc"
              }
              TST_container_dm_hbase = container "appliance of hbase" {
              description "Instance of application runs on hbase "
              tags "hbase"
              }
              TST_container_dm_hdfs = container "appliance of hdfs" {
              description "Instance of application runs on hdfs "
              tags "hdfs"
              }
              TST_container_dm_hive = container "appliance of hive" {
              description "Instance of application runs on hive "
              tags "hive"
              }
              TST_container_dm_http = container "appliance of http" {
              description "Instance of application runs on http "
              tags "http"
              }
              TST_container_dm_https = container "appliance of https" {
              description "Instance of application runs on https "
              tags "https"
              }
              TST_container_dm_hue = container "appliance of hue" {
              description "Instance of application runs on hue "
              tags "hue"
              }
              TST_container_dm_iceberg = container "appliance of iceberg" {
              description "Instance of application runs on iceberg "
              tags "iceberg"
              }
              TST_container_dm_influxdb = container "appliance of influxdb" {
              description "Instance of application runs on influxdb "
              tags "influxdb"
              }
              TST_container_dm_jupiterhub = container "appliance of jupiterhub" {
              description "Instance of application runs on jupiterhub "
              tags "jupiterhub"
              }
              TST_container_dm_k8ssandra = container "appliance of k8ssandra" {
              description "Instance of application runs on k8ssandra "
              tags "k8ssandra"
              }
              TST_container_dm_kafka = container "appliance of kafka" {
              description "Instance of application runs on kafka "
              tags "kafka"
              }
              TST_container_dm_liquibase = container "appliance of liquibase" {
              description "Instance of application runs on liquibase "
              tags "liquibase"
              }
              TST_container_dm_mlflow = container "appliance of mlflow" {
              description "Instance of application runs on mlflow "
              tags "mlflow"
              }
              TST_container_dm_mondrian = container "appliance of mondrian" {
              description "Instance of application runs on mondrian "
              tags "mondrian"
              }
              TST_container_dm_mongodb = container "appliance of mongodb" {
              description "Instance of application runs on mongodb "
              tags "mongodb"
              }
              TST_container_dm_mqs = container "appliance of mqs" {
              description "Instance of application runs on mqs "
              tags "mqs"
              }
              TST_container_dm_mqtt = container "appliance of mqtt" {
              description "Instance of application runs on mqtt "
              tags "mqtt"
              }
              TST_container_dm_mssql = container "appliance of mssql" {
              description "Instance of application runs on mssql "
              tags "mssql"
              }
              TST_container_dm_mysql = container "appliance of mysql" {
              description "Instance of application runs on mysql "
              tags "mysql"
              }
              TST_container_dm_nifi = container "appliance of nifi" {
              description "Instance of application runs on nifi "
              tags "nifi"
              }
              TST_container_dm_ntp = container "appliance of ntp" {
              description "Instance of application runs on ntp "
              tags "ntp"
              }
              TST_container_dm_oozie = container "appliance of oozie" {
              description "Instance of application runs on oozie "
              tags "oozie"
              }
              TST_container_dm_opensearch = container "appliance of opensearch" {
              description "Instance of application runs on opensearch "
              tags "opensearch"
              }
              TST_container_dm_oracle = container "appliance of oracle" {
              description "Instance of application runs on oracle "
              tags "oracle"
              }
              TST_container_dm_oracle_client = container "appliance of oracle_client" {
              description "Instance of application runs on oracle_client "
              tags "oracle_client"
              }
              TST_container_dm_pop3 = container "appliance of pop3" {
              description "Instance of application runs on pop3 "
              tags "pop3"
              }
              TST_container_dm_postgre = container "appliance of postgre" {
              description "Instance of application runs on postgre "
              tags "postgre"
              }
              TST_container_dm_postgresql = container "appliance of postgresql" {
              description "Instance of application runs on postgre "
              tags "postgresql"
              }
              TST_container_dm_qdrant = container "appliance of qdrant" {
              description "Instance of application runs on qdrant "
              tags "qdrant"
              }
              TST_container_dm_qliksense = container "appliance of qliksense" {
              description "Instance of application runs on qliksense "
              tags "qliksense"
              }
              TST_container_dm_rabbitmq = container "appliance of rabbitmq" {
              description "Instance of application runs on rabbitmq "
              tags "rabbitmq"
              }
              TST_container_dm_redis = container "appliance of redis" {
              description "Instance of application runs on redis "
              tags "redis"
              }
              TST_container_dm_rest = container "appliance of rest" {
              description "Instance of application runs on rest "
              tags "rest"
              }
              TST_container_dm_s3 = container "appliance of s3" {
              description "Instance of application runs on s3 "
              tags "s3"
              }
              TST_container_dm_seatunnel = container "appliance of seatunnel" {
              description "Instance of application runs on seatunnel "
              tags "seatunnel"
              }
              TST_container_dm_sftp = container "appliance of sftp" {
              description "Instance of application runs on sftp "
              tags "sftp"
              }
              TST_container_dm_smb1 = container "appliance of smb1" {
              description "Instance of application runs on smb1 "
              tags "smb1"
              }
              TST_container_dm_smb2 = container "appliance of smb2" {
              description "Instance of application runs on smb2 "
              tags "smb2"
              }
              TST_container_dm_smpp = container "appliance of smpp" {
              description "Instance of application runs on smpp "
              tags "smpp"
              }
              TST_container_dm_smtp = container "appliance of smtp" {
              description "Instance of application runs on smtp "
              tags "smtp"
              }
              TST_container_dm_soap = container "appliance of soap" {
              description "Instance of application runs on soap "
              tags "soap"
              }
              TST_container_dm_spark = container "appliance of spark" {
              description "Instance of application runs on spark "
              tags "spark"
              }
              TST_container_dm_ssh1 = container "appliance of ssh1" {
              description "Instance of application runs on ssh1 "
              tags "ssh1"
              }
              TST_container_dm_ssh2 = container "appliance of ssh2" {
              description "Instance of application runs on ssh2 "
              tags "ssh2"
              }
              TST_container_dm_ssl = container "appliance of ssl" {
              description "Instance of application runs on ssl "
              tags "ssl"
              }
              TST_container_dm_tarantool = container "appliance of tarantool" {
              description "Instance of application runs on tarantool "
              tags "tarantool"
              }
              TST_container_dm_tcp = container "appliance of tcp" {
              description "Instance of application runs on tcp "
              tags "tcp"
              }
              TST_container_dm_telnet = container "appliance of telnet" {
              description "Instance of application runs on telnet "
              tags "telnet"
              }
              TST_container_dm_tftp = container "appliance of tftp" {
              description "Instance of application runs on tftp "
              tags "tftp"
              }
              TST_container_dm_tls = container "appliance of tls" {
              description "Instance of application runs on tls "
              tags "tls"
              }
              TST_container_dm_tls10 = container "appliance of tls10" {
              description "Instance of application runs on tls10 "
              tags "tls10"
              }
              TST_container_dm_tls11 = container "appliance of tls11" {
              description "Instance of application runs on tls11 "
              tags "tls11"
              }
              TST_container_dm_tls13 = container "appliance of tls13" {
              description "Instance of application runs on tls13 "
              tags "tls13"
              }
              TST_container_dm_trino = container "appliance of trino" {
              description "Instance of application runs on trino "
              tags "trino"
              }
            }

            prog_grp = group "Технорадар - Языки" {

              TST_container_prog_c = container "appliance of c" {
              description "Instance of application runs on c "
              tags "c"
              }
              TST_container_prog_cpp = container "appliance of cpp" {
              description "Instance of application runs on cpp "
              tags "cpp"
              }
              TST_container_prog_csharp = container "appliance of csharp" {
              description "Instance of application runs on csharp "
              tags "csharp"
              }
              TST_container_prog_css = container "appliance of css" {
              description "Instance of application runs on css "
              tags "css"
              }
              TST_container_prog_dotnetframework = container "appliance of dotnetframework" {
              description "Instance of application runs on dotnetframework "
              tags "dotnetframework"
              }
              TST_container_prog_erlang = container "appliance of erlang" {
              description "Instance of application runs on erlang "
              tags "erlang"
              }
              TST_container_prog_go = container "appliance of go" {
              description "Instance of application runs on go "
              tags "go"
              }
              TST_container_prog_groovy = container "appliance of groovy" {
              description "Instance of application runs on groovy "
              tags "groovy"
              }
              TST_container_prog_hcl = container "appliance of hcl" {
              description "Instance of application runs on hcl "
              tags "hcl"
              }
              TST_container_prog_html = container "appliance of html" {
              description "Instance of application runs on html "
              tags "html"
              }
              TST_container_prog_java = container "appliance of java" {
              description "Instance of application runs on java "
              tags "java"
              }
              TST_container_prog_jquery = container "appliance of jquery" {
              description "Instance of application runs on jquery "
              tags "jquery"
              }
              TST_container_prog_js = container "appliance of js" {
              description "Instance of application runs on js "
              tags "js"
              }
              TST_container_prog_kotlin = container "appliance of kotlin" {
              description "Instance of application runs on kotlin "
              tags "kotlin"
              }
              TST_container_prog_lua = container "appliance of lua" {
              description "Instance of application runs on lua "
              tags "lua"
              }
              TST_container_prog_objectivec = container "appliance of objectivec" {
              description "Instance of application runs on objectivec "
              tags "objectivec"
              }
              TST_container_prog_pascal = container "appliance of pascal" {
              description "Instance of application runs on pascal "
              tags "pascal"
              }
              TST_container_prog_perl = container "appliance of perl" {
              description "Instance of application runs on perl "
              tags "perl"
              }
              TST_container_prog_php = container "appliance of php" {
              description "Instance of application runs on php "
              tags "php"
              }
              TST_container_prog_python = container "appliance of python" {
              description "Instance of application runs on python "
              tags "python"
              }
              TST_container_prog_ruby = container "appliance of ruby" {
              description "Instance of application runs on ruby "
              tags "ruby"
              }
              TST_container_prog_rust = container "appliance of rust" {
              description "Instance of application runs on rust "
              tags "rust"
              }
              TST_container_prog_scala = container "appliance of scala" {
              description "Instance of application runs on scala "
              tags "scala"
              }
              TST_container_prog_smalltalk = container "appliance of smalltalk" {
              description "Instance of application runs on smalltalk "
              tags "smalltalk"
              }
              TST_container_prog_swift = container "appliance of swift" {
              description "Instance of application runs on swift "
              tags "swift"
              }
              TST_container_prog_ts = container "appliance of ts" {
              description "Instance of application runs on ts "
              tags "ts"
              }


            }

            k8s_grp = group "Kubernetes resources" {
             
              TST_container_k8s_k8s_api = container "appliance of k8s_api" {
              description "Instance of application runs on k8s_api "
              tags "k8s_api"
              }
              TST_container_k8s_k8s_c_c_m = container "appliance of k8s_c_c_m" {
              description "Instance of application runs on k8s_c_c_m "
              tags "k8s_c_c_m"
              }
              TST_container_k8s_k8s_c_m = container "appliance of k8s_c_m" {
              description "Instance of application runs on k8s_c_m "
              tags "k8s_c_m"
              }
              TST_container_k8s_k8s_c_role = container "appliance of k8s_c_role" {
              description "Instance of application runs on k8s_c_role "
              tags "k8s_c_role"
              }
              TST_container_k8s_k8s_cluster = container "appliance of k8s_cluster" {
              description "Instance of application runs on k8s_cluster "
              tags "k8s_cluster"
              }
              TST_container_k8s_k8s_cm = container "appliance of k8s_cm" {
              description "Instance of application runs on k8s_cm "
              tags "k8s_cm"
              }
              TST_container_k8s_k8s_control_plane = container "appliance of k8s_control_plane" {
              description "Instance of application runs on k8s_control_plane "
              tags "k8s_control_plane"
              }
              TST_container_k8s_k8s_crb = container "appliance of k8s_crb" {
              description "Instance of application runs on k8s_crb "
              tags "k8s_crb"
              }
              TST_container_k8s_k8s_crd = container "appliance of k8s_crd" {
              description "Instance of application runs on k8s_crd "
              tags "k8s_crd"
              }
              TST_container_k8s_k8s_cronjob = container "appliance of k8s_cronjob" {
              description "Instance of application runs on k8s_cronjob "
              tags "k8s_cronjob"
              }
              TST_container_k8s_k8s_deploy = container "appliance of k8s_deploy" {
              description "Instance of application runs on k8s_deploy "
              tags "k8s_deploy"
              }
              TST_container_k8s_k8s_ds = container "appliance of k8s_ds" {
              description "Instance of application runs on k8s_ds "
              tags "k8s_ds"
              }
              TST_container_k8s_k8s_ep = container "appliance of k8s_ep" {
              description "Instance of application runs on k8s_ep "
              tags "k8s_ep"
              }
              TST_container_k8s_k8s_etcd = container "appliance of k8s_etcd" {
              description "Instance of application runs on k8s_etcd "
              tags "k8s_etcd"
              }
              TST_container_k8s_k8s_group = container "appliance of k8s_group" {
              description "Instance of application runs on k8s_group "
              tags "k8s_group"
              }
              TST_container_k8s_k8s_hpa = container "appliance of k8s_hpa" {
              description "Instance of application runs on k8s_hpa "
              tags "k8s_hpa"
              }
              TST_container_k8s_k8s_ing = container "appliance of k8s_ing" {
              description "Instance of application runs on k8s_ing "
              tags "k8s_ing"
              }
              TST_container_k8s_k8s_job = container "appliance of k8s_job" {
              description "Instance of application runs on k8s_job "
              tags "k8s_job"
              }
              TST_container_k8s_k8s_k_proxy = container "appliance of k8s_k_proxy" {
              description "Instance of application runs on k8s_k_proxy "
              tags "k8s_k_proxy"
              }
              TST_container_k8s_k8s_kubelet = container "appliance of k8s_kubelet" {
              description "Instance of application runs on k8s_kubelet "
              tags "k8s_kubelet"
              }
              TST_container_k8s_k8s_limits = container "appliance of k8s_limits" {
              description "Instance of application runs on k8s_limits "
              tags "k8s_limits"
              }
              TST_container_k8s_k8s_netpol = container "appliance of k8s_netpol" {
              description "Instance of application runs on k8s_netpol "
              tags "k8s_netpol"
              }
              TST_container_k8s_k8s_node = container "appliance of k8s_node" {
              description "Instance of application runs on k8s_node "
              tags "k8s_node"
              }
              TST_container_k8s_k8s_ns = container "appliance of k8s_ns" {
              description "Instance of application runs on k8s_ns "
              tags "k8s_ns"
              }
              TST_container_k8s_k8s_pod = container "appliance of k8s_pod" {
              description "Instance of application runs on k8s_pod "
              tags "k8s_pod"
              }
              TST_container_k8s_k8s_psp = container "appliance of k8s_psp" {
              description "Instance of application runs on k8s_psp "
              tags "k8s_psp"
              }
              TST_container_k8s_k8s_pv = container "appliance of k8s_pv" {
              description "Instance of application runs on k8s_pv "
              tags "k8s_pv"
              }
              TST_container_k8s_k8s_pvc = container "appliance of k8s_pvc" {
              description "Instance of application runs on k8s_pvc "
              tags "k8s_pvc"
              }
              TST_container_k8s_k8s_quota = container "appliance of k8s_quota" {
              description "Instance of application runs on k8s_quota "
              tags "k8s_quota"
              }
              TST_container_k8s_k8s_rb = container "appliance of k8s_rb" {
              description "Instance of application runs on k8s_rb "
              tags "k8s_rb"
              }
              TST_container_k8s_k8s_role = container "appliance of k8s_role" {
              description "Instance of application runs on k8s_role "
              tags "k8s_role"
              }
              TST_container_k8s_k8s_rs = container "appliance of k8s_rs" {
              description "Instance of application runs on k8s_rs "
              tags "k8s_rs"
              }
              TST_container_k8s_k8s_sa = container "appliance of k8s_sa" {
              description "Instance of application runs on k8s_sa "
              tags "k8s_sa"
              }
              TST_container_k8s_k8s_sc = container "appliance of k8s_sc" {
              description "Instance of application runs on k8s_sc "
              tags "k8s_sc"
              }
              TST_container_k8s_k8s_sched = container "appliance of k8s_sched" {
              description "Instance of application runs on k8s_sched "
              tags "k8s_sched"
              }
              TST_container_k8s_k8s_secret = container "appliance of k8s_secret" {
              description "Instance of application runs on k8s_secret "
              tags "k8s_secret"
              }
              TST_container_k8s_k8s_sts = container "appliance of k8s_sts" {
              description "Instance of application runs on k8s_sts "
              tags "k8s_sts"
              }
              TST_container_k8s_k8s_svc = container "appliance of k8s_svc" {
              description "Instance of application runs on k8s_svc "
              tags "k8s_svc"
              }
              TST_container_k8s_k8s_user = container "appliance of k8s_user" {
              description "Instance of application runs on k8s_user "
              tags "k8s_user"
              }
              TST_container_k8s_k8s_vol = container "appliance of k8s_vol" {
              description "Instance of application runs on k8s_vol "
              tags "k8s_vol"
              }

            }

            aux_grp = group "Не вошедшие в Технорадар технологии" {
             
              TST_container_aux_ignite = container "appliance of ignite" {
              description "Instance of application runs on ignite "
              tags "ignite"
              }
              TST_container_aux_hadoop = container "appliance of hadoop" {
              description "Instance of application runs on hadoop "
              tags "hadoop"
              }
              TST_container_aux_yarn = container "appliance of yarn" {
              description "Instance of application runs on yarn "
              tags "yarn"
              }
              TST_container_aux_beeline = container "appliance of some generic system beeline" {
              description "Instance of application runs on some generic system beeline "
              tags "beeline"
              }
            }

        }
        
        production = deploymentEnvironment "RU.TST.TST-PROD" {
            protected = deploymentNode "Protected STD OPERATIONS" {
                
                m3ost23 = deploymentNode "RU.YDC.YD-M3-OST23-VEGA" {
                    tags "openstack, view_2xl"
                    description "Vega Openstack Cluster 23"
            
                    dn_tst_db_001 = deploymentNode "RU.YDC.TST-PRD-PG14STB-001.DATABASE-PROD-PG.CLOUD.VIMPELCOM.RU" {
                        tags "linux, deployment, view_2xl"
                        properties {
                            "type"              "vm"
                            "host"              "fmdm-gn-prd-pg14stb-001.database-prod-pg.cloud.vimpelcom.ru"
                            "ip"                "10.29.183.126"
                            "flavour"           "cpu4ram32"
                            "volume_size"       "500"
                        }

                        deploymentNode "RU.RU.YDC.TST-PRD-PG14STB-001.DATABASE-PROD-PG.CLOUD.VIMPELCOM.RU.TST-PRD-PG14STB-001.DATABASE-PROD-PG.CLOUD.VIMPELCOM.RU\PG5432.TST" {
                            tags "deployment, postgresql, view_2xl"
                            properties {
                                "type"              "postgresql"
                                "version"           "14"
                                "backup_strategies" "backup-on"
                                "volume_size"       "500"
                                "url"               "postgres://tst-prd-pg14stb-001.database-prod-pg.cloud.vimpelcom.ru:5432,tst-prd-pg14stb-002.database-prod-pg.cloud.vimpelcom.ru:5432/poweruser?target_session_attrs=read-write"
                                "host"              "tst-gn-prd-pg14stb-001.database-prod-pg.cloud.vimpelcom.ru"
                                "ip"                "10.29.183.256"
                                "flavour"           "cpu4ram32"
                            }

                            containerInstance TST.TST_container_dm_postgresql

                        }
                    }
                }

                ost9 = deploymentNode "RU.YDC.YD-M5-OST9-K8S" {
                    tags "openstack"
                    description "Vega Openstack Cluster 9"
            
                    dn_yd_m5_k51 = deploymentNode "RU.YDC.YD-M5-K51" {
                        description "Vega k8s cluster yd-m5-k51"
                        tags "k8s_cluster"
                        properties {
                            "type"          "k8s-cluster"
                            "ip"            "10.26.152.0/23"
                            "flavour"       "-1"
                            "volume_size"   "-1"
                        }

                        dn_tst_ns = deploymentNode "TST--PROD-COMMON-M5K51.YD-M5-K51"  {
                            tags "k8s_ns"
                            description "tst--prod-common-m5k51 Namespace for standard services"
                            properties {
                                "type"          "k8s-ns"
                                "flavour"       "cpu25ram64"
                                "volume_size"   "1"
                            }

                            ing_tst_prod_common_m5k51 = infrastructureNode "yd-m5-k51 Ingress" {
                                tags "k8s_ing"
                                description "Коммунальный Ingress https://*.apps.yd-m5-k51.vimpelcom.ru"
                                properties {
                                    "type"  "k8s-ingress"
                                    "ip"    "10.26.160.000"
                                }
                            }

                            dn_tst_bobff = deploymentNode "back-office-backend-for-frontend" {
                                tags "k8s_pod"
                                description "deployment"
                                instances 1
                                properties {
                                    "type"          "pod"
                                    "image"         "debian"
                                    "flavour"       "cpu0.128ram0.5"
                                    "volume_size"   "0"
                                }
                                containerInstance TST.TST_container_fw_dotnet
                          
                            }
                        }
                    }
                }

                dn_mapic = deploymentNode "gw.mapic.vimpelcom.ru" {
                    properties {
                        "host"  "gw.mapic.vimpelcom.ru"
                        "ip"    "10.26.181.2"
                    }
                    softwareSystemInstance MAPIC
                }

                dn_idp = deploymentNode "sso.vimpelcom.ru" {
                    properties {
                        "host"  "sso.vimpelcom.ru"
                        "ip"    "10.28.47.60"
                    }
                    softwareSystemInstance IDP
                }
            }
        
            
        
        }

        production.protected.ost9.dn_yd_m5_k51  -> production.protected.m3ost23.dn_tst_db_001 "Data exchange" "TCP:5432"  {
            tags nw
            properties {
                "nw_status" "Существующая"
                "technology" "HTTPS,TLS,PostgreSQL"
            }
        }

        production.protected.ost9.dn_yd_m5_k51  -> production.protected.dn_idp "Token verification" "TCP:443"  {
            tags nw
            properties {
                "nw_status" "Существующая"
                "technology" "HTTPS,TLS,REST"
            }
        }

        production.protected.dn_mapic   -> production.protected.ost9.dn_yd_m5_k51.dn_tst_ns.ing_tst_prod_common_m5k51 "Запросы на изменения" "TCP:443"  {
            tags nw
            properties {
                "nw_status" "Существующая"
                "technology" "HTTPS,TLS,REST"
            }
        }



    }

    views {
        # Конфигурируем настройки отображения plant uml
        properties {
            kroki.url           "https://kroki.vimpelcom.ru"
            kroki.format        "svg"
            structurizr.sort created
            structurizr.tooltips true
        }

        branding {
          logo "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAUAAAAFACAMAAAD6TlWYAAAC+lBMVEVHcEz82gDzxwC1kABkTwBpUgBXRAA2KgATDwAGBQAAAAABAQAAAAABAQAAAAAAAAAAAAAaFAA2KgBdSQCUdAC/lgDmtQD+yAD/yAD+xwD+xwD/xwD+yAD/xwD/xwD/yAD+xwD/xwD8xgD+xwD/yQD3xgD71ACDZwB9YgBhTAA8LwAzKAApIAAlHAATDgANCgAAAAADAgASDgAwJgBpUgCohADfrwD8xgD/ygD/yAD/xwD/xwD/xwD/yAD/xwD/xwD/yAD7xQD+xwD/yAD+xwD/xwC9lgBYRQA/MQAOCwAIBgAiGgBlTwC4kADxvgD/yAD+yAD7xQDywACwigCDZwAvJQAbFQALCABHOADuuwD+xwBQRABENQAoHwBENQCyiwD3wwD4yACbeQBxWAAsIgBdSQDUpgD+yQD/xwDLoABeSgA6LQAeGAAkHQCefAD1wQD/yQD/xwCNbgBZRQAVEADltAD/xwCdewABAQBPPQD+xwCyjABDNQAbFQD+xwD/xwBXRAA/MQDsugD+xwCviQD+yABhTAAsIgDotgAYEwAPCwDInQBBMgCrhgD/ywCYdwDuuwC9lACJawByWQBPPgD6xQBHOAC9lAA0KQCdfgCXdwDFmwAnHwAHBQAmHgB8YQD5wwByWQAQDQAGBQAPDAB1XAAVEAAQDAARDQDBlwDbrAAKBwAIBgACAQBLOwDzvwAQDQAIBgACAgAFBAClgQABAQAEAwAFBAAAAAA7LgAAAAAAAAAHBQAEAwDwvQAAAAABAQAAAABaRgC1jgACAgAAAADLnwAAAADDmQCEaAAAAACRcgC7kgDjswAAAACbeQCAZAABAAAIBgAAAAA4LADRpABRPwDqtwDXqQB5XgBuVgC8kwChfgCefQB1XAD+xwCObwDZqgD9yACVdQD/xwDOoQDhsQBVQwD0vwDdrgBsVAA/MQDNoQCzjABzWgCgfgD0wAC6kgDEmgCKbACFaABnUQDNoQCWdQCPcAChfgCVdQBnUAAhGgBCNAAvwUWdAAAA/nRSTlMABA0cLEVWdH6Xs9Dl9fv+6+7y7uzt7+vm3trSxrmkl4VrWkErGwg8WW6MrMvZ5/D///////////////789/HjwK6NclMxJp+9+P//////7kYiFkBv5vf///83AtP2////Elyg7////8sus+X///////p3wP//tWr//2JN3v+dTtT//z7//////////8r////4u/+shf/p//8MFf///Lv///8fT93/yEMK///pb6f//xk9yP//wDFX3//Z7wUS/4ytoP//KDf/R///X////7n//4F4aP////////9Y/8eNe//e///z////3ejt7Ozq4LWevvnQfsY3i4B9h3/imsXE2yIAABliSURBVHgB7ME3AQAgAAAg97Z/XVt4AQEAAAAAAICvYsqltj7m2uc+9upBOZYgCsBwxaUb2zZOh9OTtTe2bdu2beNNb09szHo33yP8dWBrZ/vP3sHRydnF1c3N3cPTy9vH188/IDAoOMTc7K/VG6EWYeERkVHRMbFxpBw8Q4DiExKTklMoTBOpHC6P7yUQisQSaUjoXzeGucwqQq6IcVCmIbCzs4OPoPSMzCySED8gMTnZngK/gJxcc5Ne2bz8ArmisKgYAUJA2MGnikuSSl8mZNCpXD6pWJZniitdzsSrqIxH8FNpVdU1bxPeVeR5+YrLak3r5Mnq6isaSDw7+I3ixqbmlwVfRmzxC8w1M5F6rQVt7R1pwEZnV3cPjT/WyxcGBIcaf72+/sIBZvTYSUsc/LQgGUT3IbExNzSTDbcVDoyASkY/LfjQUDhmpLtcO14/MYlAZYnd+Es9HI+p6VqjG77WvpnKNFCHtCSKxl+jud7iYGMaw9D8+vb4EVCT2Tn8vVS+37yxXMPauraGNFCftIVvR5BYxNlCiTFsssVwfxECtVpKwT9CcwVjeQaeL6SgYnIE1Gx5pQf/UG9LQIgB58srqFgFO1C3tXUK/xinJcBQp7C2YGMVNAFtbuFf6PUONDfEz1unmAQN2f5VQJyysztuaB/ZLL+taAQ0Ze9XAYmspP0wM0PqJztoQAB6E5DGh5tHBxYGk888IqYYGHqywkzBnuOTaOtTw9jeMIUSWNDUE3koSK0vK6PCyvW/39mBwwho1to5hVkUPL8YiT040/fxs4q+BE1LT+7BLFCZk3B5ZaXXQ3gWGQeaV9KNWaBxc1cxQKyN/g5huTbGj7juwewK3twCjFxehelpv1ObWNCGtEwKs0L3rMwCSRhr85+9++CJK9nyAF74RSfwy8Fx4ubdcwFDnXL2eDY0YYJCw6AFZiVgJDWmLIHVHonxNkPT0F43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"
          font "Beeline Sans"
        }

        # Задаем стили для отображения
        
        // Это базовый набор тем, должен быть подключен всегда
        themes  "beeline_basic.json" "beeline_tr_icons.json"

        // Этот набор тем надо подключить, чтобы отобразить на дииграммах 
        // 1. классы компонентов по технорадару (разная толщина рамок для фреймворков, инфраструктуры, языков программирования и управления данными), 
        // 2. adoption статус (цветные рамки) и 
        // 3. статус Недопустимо КИ - пунктирная рамка 

        // themes  "kubernetes.json" "tr_frameworks_and_tools.json" "tr_platforms_and_infrastructure.json" "tr_data_management.json" "tr_programming_languages.json" "tr_auxiliary_techs.json"
        
        

        
        

        # Диаграмма контекста
        systemContext TST {
            title "Контекстная диаграмма"
            include *
            include MOBILEAPP person_user
            autoLayout
        }
        
        container TST {
            title "Фреймворки и инструменты"
            include *
            exclude TST.infr_grp TST.dm_grp TST.prog_grp TST.k8s_grp TST.aux_grp
            autoLayout lr
        }

        container TST {
            title "Платформа и инфраструктура"
            include *
            exclude TST.fw_grp TST.dm_grp TST.prog_grp TST.k8s_grp TST.aux_grp
            autoLayout lr
        }

        container TST {
            title "Управление данными"
            include *
            exclude TST.fw_grp TST.infr_grp TST.prog_grp TST.k8s_grp TST.aux_grp
            autoLayout
        }

        container TST {
            title "Языки"
            include *
            exclude TST.fw_grp TST.infr_grp TST.dm_grp TST.k8s_grp TST.aux_grp
            autoLayout
        }

        container TST {
            title "Ресурсы Kubernetes"
            include *
            exclude TST.fw_grp TST.infr_grp TST.dm_grp TST.prog_grp TST.aux_grp
            autoLayout
        }

        container TST {
            title "Не вошедшие в Технорадар технологии"
            include *
            exclude TST.fw_grp TST.infr_grp TST.dm_grp TST.prog_grp TST.k8s_grp
            autoLayout
        }

        container TST {
            title "Все типы элементов"
            include *
            autoLayout
        }


        deployment * "RU.TST.TST-PROD" "Network" "Сетевая диаграмма системы TST и смежных систем" {
            include *
            title "Сетевая диаграмма"
            exclude "relationship.tag!=nw"
            exclude "element.tag==not-for-nw"
            exclude "relationship.tag==not-for-nw"
            properties {
                "view_type" "network"
            }
       
        }

        deployment TST "RU.TST.TST-PROD" "Production" "Диаграмма развертывания системы TST и смежных систем" {
            include *
            autoLayout
            title "Диаграмма развертывания"
            exclude "element.tag==for_nw"
       
            exclude "*->*" "element.type==infrastructureNode" "element.type==softwareSystemInstance"
            properties {
                "view_type" "deployment"
            }

        }

    }
}
