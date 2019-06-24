function _loadenv_complete() {
  local envs=$(ls ~/env/*.asc  | grep '.env.asc' | sed -E 's/.*\/env\/(.*).env.asc/\1/')
  _alternative "dis:user directories:($envs)"
}

compdef _loadenv_complete loadenv

function _loadenv_list() {
  ls ~/env/*.env.asc |xargs -n 1 basename | sed 's/.env.asc//'
}

function _loadenv_show() {
  if [[ "$#" -lt 1 ]]; then
    echo "usage: loadenv <env>"
  fi

  local env=$1
  local file="${HOME}/env/${env}.env.asc"
  if [[ ! -f "${file}" ]]; then
    echo "file \"${file}\" does not exists"
    return
  fi

  gpg -d ~/env/${env}.env.asc 2>/dev/null
}

function _loadenv_decode() {
  if [[ "$#" -lt 2 ]]; then
    echo "usage: loadenv decode <env>"
  fi

  local env=$2
  local file="${HOME}/env/${env}.env.asc"
  if [[ ! -f "${file}" ]]; then
    echo "file \"${file}\" does not exists"
    return
  fi

  local output="${HOME}/env/${env}.env"
  gpg -d ~/env/${env}.env.asc 2>/dev/null > ${output}
  echo "wrote '${output}'"
}

function _loadenv_encode() {
  if [[ "$#" -lt 2 ]]; then
    echo "usage: loadenv encode <env>"
    return
  fi

  local env=$2
  local file="${HOME}/env/${env}.env"
  if [[ ! -f "${file}" ]]; then
    echo "file \"${file}\" does not exists"
    return
  fi

  local env=$2
  echo $env
  gpg -ea ~/env/${env}.env
}

function _loadenv_load() {
  local env=$1
  local file="${HOME}/env/${env}.env.asc"
  if [[ ! -f "${file}" ]]; then
    echo "file \"${file}\" does not exists"
    return
  fi

  gpg -d ~/env/${env}.env.asc 2> /dev/null 1> /dev/null # handle the password xcurse
  source <(gpg -d ~/env/${env}.env.asc)
}

function loadenv() {
  if [[ "$#" -lt 1 ]]; then
    echo
    _loadenv_list
    echo

    echo "usage: loadenv [list, encode, decode, show, <env-name>"
    echo
    return
  fi

case "$1" in
  list)
    _loadenv_list
    ;;
  encode)
    _loadenv_encode "$@"
    ;;
  decode)
    _loadenv_decode "$@"
    ;;
  show)
    shift
    _loadenv_show "$@"
    ;;
  *)
    _loadenv_load "$@"
    ;;
esac

}

