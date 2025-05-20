#!/bin/bash

OUTPUT_NAME=""

check_c_compiler(){
    # Проверка наличия исполняемого файла g++ в PATH
    if command -v g++ &> /dev/null; then
        g++ --version | head -n 1
        OUTPUT_NAME="НАЙДЕН g++"
    else
        OUTPUT_NAME="НЕ НАЙДЕН g++"
        echo "   (g++ не найден в системных директориях, указанных в PATH)"
    fi
}


check_c_compiler
echo "$OUTPUT_NAME"