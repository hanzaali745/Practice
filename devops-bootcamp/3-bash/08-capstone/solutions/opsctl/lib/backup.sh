# shellcheck shell=bash
# opsctl backup — timestamped tar.gz with sha256 and retention.

cmd_backup() {
    local keep=7 opt
    OPTIND=1
    while getopts ":nk:" opt; do
        case "$opt" in
            n) DRY_RUN=true ;;
            k) keep="$OPTARG" ;;
            *) die "usage: opsctl backup [-n] [-k KEEP] SOURCE DEST" ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    [[ $# -eq 2 ]] || die "usage: opsctl backup [-n] [-k KEEP] SOURCE DEST"
    is_positive_int "$keep" || die "-k must be a positive integer"
    require_cmd tar sha256sum

    local source dest name archive
    [[ -e $1 ]] || die "source not found: $1"
    source="$(realpath "$1")"
    dest="$2"
    name="$(basename "$source")"
    archive="$dest/${name}-$(date +%Y%m%d-%H%M%S).tar.gz"

    run mkdir -p "$dest"
    info "backing up $source -> $archive"
    run tar -czf "$archive" -C "$(dirname "$source")" "$name"
    if ! $DRY_RUN; then
        (cd "$dest" && sha256sum "${archive##*/}" > "${archive##*/}.sha256")
        ok "backup created ($(du -h "$archive" | cut -f1))"
    fi

    local old
    while IFS= read -r old; do
        info "pruning $old"
        run rm -f "$old" "$old.sha256"
    done < <(find "$dest" -maxdepth 1 -name "${name}-*.tar.gz" -printf '%T@ %p\n' 2>/dev/null \
             | sort -rn | tail -n +"$(( keep + 1 ))" | cut -d' ' -f2-)
}
