#!/bin/bash


# Проверка наличия исполняемого файла g++ в PATH
HAS_CPP=1
check_cpp(){
    if command -v g++ &> /dev/null; then
        g++ --version | head -n 1
        HAS_CPP=0
    else
        HAS_CPP=1
        echo "g++ не найден в системных директориях, указанных в PATH" >&2
    fi
}




# Проверка наличия исполняемого файла TeX в PATH
HAS_TEX=1
check_tex(){
    if command -v pdflatex &> /dev/null; then
        pdflatex --version | head -n 1
        HAS_TEX=0
    else
        HAS_TEX=1
        echo "pdflatex не найден." >&2
    fi
}

# Получение имени выходного файла
get_output_file_name(){
    if test -f $1; then
        output_word=$(grep -oE '&Output:[[:space:]]*[^[:space:]]+' $1)
        output_word=$(echo "$output_word" | sed 's/^&Output:[[:space:]]*//')
        output_word=$(echo "$output_word" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        echo "$output_word"
    else
        echo "Ошибка: Файл '$1' не найден или не является обычным файлом." >&2
        exit 1
    fi
}



original_dir=$(pwd)
compiled_file=$1
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


cp $compiled_file $TEMP_DIR/$compiled_file
cd $TEMP_DIR/

compiled_file_extension="${compiled_file##*.}"

if [[ "$compiled_file" == "$compiled_file_extension" ]]; then
    echo "Файл $compiled_file не имеет расширения" >&2
    exit 1
fi


case "$compiled_file_extension" in
    cpp)
        check_cpp
        if [[ $HAS_CPP == 0 ]]; then
                g++ "$compiled_file" -o "$output_file_name"
                mv "$output_file_name" "$original_dir/"
                echo "completed!"
            else
                exit 1
        fi
        ;;
    tex)
        check_tex
        if [[ $HAS_TEX == 0 ]]; then
                pdflatex $compiled_file
                mv $compiled_file $original_dir/
                echo "completed!"
            else
                exit 1
        fi
        ;;
    *)
        echo "Ошибка: формат .$compiled_file_extension не поддерживается" >&2
        exit 1
        ;;
esac
