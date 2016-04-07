# go tool

__i_tool_complete() {
  local icas_base=${ICAS_BASE:-~/dev/ecg-icas/icas}

  typeset -a commands
  commands+=(
    'console[cd into icas-console]'
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
    {vagrant,v}'[run vagrant command]'
  )
  if (( CURRENT == 2 )); then
    # explain i command
    _values 'i tool helper' ${commands[@]}
    return
  fi

  case ${words[2]} in
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
      _files -W "$icas_base/log"
      ;;
    "make-all"|"m")
      if (( CURRENT == 3)); then
        _values "make-all.bash commands" \
          "init[setup environment after checkout]" \
          "build[build packages]" \
          "rebuild[rebuild java packages]" \
          "clean[remove temp files]" \
          "migrations[run all DB migrations]" \
          "consul[start/stop consul]" \
          "fabio[start/stop fabio]" \
          "smoke[run smoke test]" \
          "supervisor[start supervisord]" \
          "thrift[regenerate all thrift files]" \
          "thriftlib[build thrift compiler for Go and update thrift lib]"
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
        "consul")
          _values "consul options" \
            "start[start consul]" \
            "stop[stop consul]" \
            "restart[restart consul]"
          ;;
        "fabio"|"supervisor")
          _values "consul options" \
            "start[start service]" \
            "stop[stop service]" \
            "restart[restart service]"
          ;;
        "smoke")
          _arguments : \
            "-env[dev, lp, prod]" \
            "-tenant[mp dba kjca]" \
            "*:next:"
          ;;
      esac
      ;;
    "svc"|"s")
      if (( CURRENT == 3)); then
        local services
        services=($(ls -d $icas_base/src/java/*/ $icas_base/src/go/src/cas/svc/*/ | xargs basename))
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
