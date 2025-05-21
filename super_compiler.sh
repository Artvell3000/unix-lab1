#!/bin/bash


# Получение имени выходного файла
get_output_file_name(){
    if test -f $1; then
        local output_word=$(grep -oE '&Output:[[:space:]]*[^[:space:]]+' $1)
        output_word=$(echo "$output_word" | sed 's/^&Output:[[:space:]]*//')
        output_word=$(echo "$output_word" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        echo "$output_word"
    else
        echo "Ошибка: Файл '$1' не найден или не является обычным файлом." >&2
        exit 1
    fi
}

init_compiler(){
    local file=$1
    local file_extension="${file##*.}"

    if [[ "$file" == "$file_extension" ]]; then
        echo "Файл $file не имеет расширения" >&2
        exit 1
    fi


    case "$file_extension" in
        cpp)
            source compiler_cpp.sh
            ;;
        tex)
            source compiler_tex.sh
            ;;
        *)
            echo "Ошибка: формат .$file_extension не поддерживается" >&2
            exit 1
            ;;
    esac
}


compiled_file=$1
original_dir=$(pwd)
output_file_name=$(get_output_file_name $1)

TEMP_DIR=$(mktemp -d)
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось создать временный каталог." >&2
    exit 1
fi

cleanup_temp_dir(){
    rm -rf "$TEMP_DIR"
}

trap cleanup_temp_dir EXIT
trap "exit 1" INT TERM HUP

init_compiler $compiled_file
cp $compiled_file $TEMP_DIR/$compiled_file
cd $TEMP_DIR/



check_compiler
if [ $? -eq 0 ]; then
    build $compiled_file $output_file_name
    if [ $? -eq 0 ]; then
        mv $output_file_name $original_dir/
        echo "completed!"
    else 
        echo "файл не создан!" >&2
    fi
fi


