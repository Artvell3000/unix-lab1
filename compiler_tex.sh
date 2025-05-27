# Проверка наличия исполняемого файла TeX в PATH
check_compiler(){
    if command -v pdflatex &> /dev/null; then
        pdflatex --version | head -n 1
        return 0
    else
        echo "pdflatex не найденв системных директориях, указанных в PATH" >&2
        return 1
    fi
}

build(){
    local compiled_file_name=$1
    local output_file_name=$2
    pdflatex -jobname="$output_file_name" "$compiled_file_name"

    if [ -f "${output_file_name}.pdf" ]; then
        return 0
    else
        return 1
    fi
}