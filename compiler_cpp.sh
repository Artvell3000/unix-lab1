# Проверка наличия исполняемого файла g++ в PATH
check_compiler(){
    if command -v g++ &> /dev/null; then
        g++ --version | head -n 1
        return 0
    else
        echo "g++ не найден в системных директориях, указанных в PATH" >&2
        return 1
    fi
}

build(){
    compiled_file_name=$1
    output_file_name=$2
    g++ $compiled_file_name -o $output_file_name

    if [ -f $output_file_name ]; then
        return 0
    else
        return 1
    fi
}