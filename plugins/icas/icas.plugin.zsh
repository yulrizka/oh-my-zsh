# go tool

function i() {
local base=${ICAS_BASE:-~/dev/ecg-icas/icas}
case "$1" in
  "")
    cd ${base}
    ;;
  "console")
    cd ${base}/../icas-console
    ;;
  "consul")
    ${base}/bin/consul $2
    ;;
  "fabio")
    cd ${base}; bin/fabio $2; cd -
    ;;
  "go")
    cd ${base}/src/go/src/cas/$2
    ;;
  "java")
    cd ${base}/src/java
    ;;
  "log")
    docker-compose logs -f --tail=50 $2
    ;;
  "make-all"|"m")
    pushd ${base} > /dev/null
    bin/make-all.bash ${@:2}
    popd > /dev/null
    ;;
  "properties")
    cd ${base}/src/java/cas-properties
    ;;
  "puppet"|"p")
    cd ${base}/../ecg-puppet-icas
    ;;
  "query"|"q")
    case "$2" in
      "port")
        local portNum=$3
        if [ ${#portNum} -ge 4 ]; 
        then
          portNum=${portNum:0:4}
        fi
        grep "$portNum" ${base}/service-ports.txt
        ;;
      "svc")
        grep "$3" ${base}/service-ports.txt 
      ;;
    *)
      echo "use i q (port|svc) (search string)"
      return 1
      ;;
  esac
  ;;
  "registry")
    cd ${base}/etc/registry
    ;;
  "svc"|"s")
    if [ -d "${base}/src/go/src/cas/svc/$2" ]; then
      cd ${base}/src/go/src/cas/svc/$2
    elif [ -d "${base}/src/java/$2" ]; then
      cd ${base}/src/java/$2
    else
      echo "could not found service $2"
      return 1
    fi
    ;;
  "thrift")
    cd ${base}/src/thrift
    ;;
  "tools")
    cd ${base}/src/go/src/cas/tools/$2
    ;;
  *)
  echo "i $1 not understood"
  return 1
  ;;
  esac
}

__i_tool_complete() {
  local icas_base=${ICAS_BASE:-~/dev/ecg-icas/icas}

  typeset -a commands
  commands+=(
    'console[cd into icas-console]'
    'consul[control consul service]'
    'fabio[control fabio service]'
    'go[cd into go directory or its children]'
    'java[cd into java directory or its children]'
    'log[cd into log directory or tail -f file inside it]'
    {make-all,m}'[icas make-all.sh]'
    'registry[cd into etc/registry]'
    'properties[cd into java/cas/properties]'
    'thrift[cd into thrift directory]'
    {svc,s}'[cd into service directory both JAVA or GO]'
    'tools[cd into tools directory or its children]'
    {puppet,p}'[cd into puppet directory]'
    {query,q}'[query either registry or port information of a service]'
  )
  if (( CURRENT == 2 )); then
    # explain i command
    _values 'i tool helper' ${commands[@]}
    return
  fi

  case ${words[2]} in
    "consul")
      _values "consul options" \
        "start[start consul]" \
        "stop[stop consul]" \
        "restart[restart consul]" \
        "clean[clean consul data]"
      ;;
    "fabio")
      _values "consul options" \
        "start[start service]" \
        "stop[stop service]" \
        "status[show status]" \
        "restart[restart service]" \
        "update[update fabio config]"
      ;;
    "go")
      if (( CURRENT == 3)); then
        _files -W "$icas_base/src/go/src/cas" -/
      fi
      ;;
    "java")
      if (( CURRENT == 3)); then
        _files -W "$icas_base/src/java" -/
      fi
      ;;
    "log")
      services=$(ls -d $icas_base/src/java/*/ $icas_base/src/go/src/cas/svc/*/ | xargs basename)
      _alternative "dirs:user directories:($services)"
      ;;
    "make-all"|"m")
      if (( CURRENT == 3)); then
        _values "make-all.bash commands" \
          "build[build packages]" \
          "clean[remove temp files]" \
          "docker[docker sub command for dependency]" \
          "init[setup environment after checkout]" \
          "migrations[run all DB migrations]" \
          "rebuild[rebuild java packages]" \
          "resetch[delete and recreate all Clickhouse tables and views]" \
          "resetes[delete and recreate all ES indices]" \
          "thrift[regenerate all thrift files]" \
          "verify[gerrit verify]"
        return
      fi
      case ${words[3]} in
        "clean")
          # hack to get -a as optional options
          _arguments -s -w : \
            "-a[clean everything]" \
            "-a[clean everything]" \
            "*:next:"
          ;;
        "build")
          _arguments -s -w : \
            "-m[Run db migrations]" \
            "-t[Run unit tests]" \
            "-i[Run integration tests]" \
            "-p[Create deployable packages (checks if local git repo is clean)]" \
            "-j[Build only java]" \
            "-g[Build only go]" \
            "*:next:"
          ;;
        "rebuild")
          if (( CURRENT == 4)); then
            local services
            services=($(ls -d $icas_base/src/java/*/ | xargs basename))
            _alternative "dirs:user directories:($services)"
          fi
          ;;
        "smoke")
          _arguments : \
            "-env[dev, lp, prod]" \
            "-tenant[mp dba kjca]" \
            "*:next:"
          ;;
      esac
      ;;
    "supervisor")
      _values "consul options" \
        "start[start consul]" \
        "stop[stop consul]" \
        "status[show status]" \
        "restart[restart consul]"
      ;;
    "svc"|"s")
      if (( CURRENT == 3)); then
        local services
        services=$(ls -d $icas_base/src/java/*/ $icas_base/src/go/src/cas/svc/*/ | xargs basename)
        _alternative "dirs:user directories:($services)"
      fi
      ;;
    "tools")
      if (( CURRENT == 3)); then
        _files -W "$icas_base/src/go/src/cas/tools" -/
      fi
      ;;
    "query"|"q")
      if (( CURRENT == 3)); then
        _values "query options" \
          "port[query service info on given port]" \
          "svc[query registy of services that matches]"
        return
      fi

      case ${words[3]} in
        "svc")
          _files -W "$icas_base/etc/registry"
      esac
      ;;
  esac
}

compdef __i_tool_complete i
