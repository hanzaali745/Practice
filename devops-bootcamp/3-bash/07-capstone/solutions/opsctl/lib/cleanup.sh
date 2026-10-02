# shellcheck shell=bash
# opsctl cleanup — delete files older than N days matching a pattern.

cmd_cleanup() {
    local days=7 pattern="*" opt
    OPTIND=1
    while getopts ":nd:p:" opt; do
        case "$opt" in
            n) DRY_RUN=true ;;
            d) days="$OPTARG" ;;
            p) pattern="$OPTARG" ;;
            *) die "usage: opsctl cleanup [-n] [-d DAYS] [-p PATTERN] DIR" ;;
        esac
    done
    shift $(( OPTIND - 1 ))
    [[ $# -eq 1 ]] || die "usage: opsctl cleanup [-n] [-d DAYS] [-p PATTERN] DIR"
    is_positive_int "$days" || die "-d must be a positive integer"

    local dir="$1"
    [[ -d $dir ]] || die "not a directory: $dir"
    [[ $(realpath "$dir") != "/" ]] || die "refusing to clean /"

    local file count=0 bytes=0
    while IFS= read -r -d '' file; do
        bytes=$(( bytes + $(stat -c %s "$file") ))
        count=$(( count + 1 ))
        run rm -f -- "$file"
        $DRY_RUN || info "deleted $file"
    done < <(find "$dir" -type f -name "$pattern" -mtime +"$(( days - 1 ))" -print0)

    ok "$count file(s), $(( bytes / 1024 )) KB $($DRY_RUN && echo 'would be ' || true)removed"
}
