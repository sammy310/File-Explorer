#!/bin/bash

print_form() {
	clear
	tput cup 0 0
	echo "===================================================== File Explorer ===================================================="
	echo "========================================================= List ========================================================="

	for ((i=2; i<30; i++))
	do
		for j in 0 35 85 119
		do
			tput cup $i $j
			echo "|"
		done
	done

	for i in 31 32 33 34 35 36 38
	do
		for j in 0 119
		do
			tput cup $i $j
			echo "|"
		done
	done

	tput cup 30 0
	echo "===================================================== Information ======================================================"
	echo "|File name: "
	echo "|File type: "
	echo "|File size: "
	echo "|Access time: "
	echo "|Permission: "
	echo "|Absolute path: "
	echo "======================================================== Total ========================================================="
	tput cup 39 0
	echo "========================================================= END =========================================================="
}

print_dir_info(){
	tput sc

	X=32
	Y=38
	DIR_SIZE=0
	R_SIZE=0
	S_SIZE=0

	TOTAL_BYTE=`get_total_size`
	for FILE in `ls`
	do
		if [ -d ${FILE} ]
		then
			DIR_SIZE=$((${DIR_SIZE} + 1))
		elif [ `is_execute ${FILE}` -eq 1 ] || [ `is_compressed ${FILE}` -eq 1 ]
		then
			S_SIZE=$((${S_SIZE} + 1))
		else
			R_SIZE=$((${R_SIZE} + 1))
		fi
	done
	TOTAL_SIZE=`convert_size ${TOTAL_BYTE}`

	tput cup $Y $X
	echo "Total: $((${DIR_SIZE} + ${R_SIZE} + ${S_SIZE})), Directory: ${DIR_SIZE}, SFile: ${S_SIZE}, NFile: ${R_SIZE}, Size: ${TOTAL_SIZE}"

	tput rc
}

get_total_size() {
	ls -l | awk '{ total += $5 }; END { print total }'
}

convert_size() {
	#"size"

	FSIZE=$1

	if [ ${FSIZE} -lt 1024 ]
	then
		echo "${FSIZE}B"
		return
	else
		FSIZE_INT=`echo "${FSIZE} / 1024" | bc`
		FSIZE=`echo "scale=2; ${FSIZE} / 1024" | bc`	
		if [ ${FSIZE_INT} -lt 1024 ]
		then
			echo "${FSIZE}K"
			return
		else
			FSIZE_INT=`echo "${FSIZE} / 1024" | bc`
			FSIZE=`echo "scale=2; ${FSIZE} / 1024" | bc`	
			if [ ${FSIZE_INT} -lt 1024 ]
			then
				echo "${FSIZE}M"
				return
			else
				FSIZE=`echo "scale=2; ${FSIZE} / 1024" | bc`
				echo "${FSIZE}G"
				return
			fi
			
		fi
	fi
}

is_execute() {
	#"file name"

	if [ -x $1 ]
	then
		echo 1
	else
		echo 0
	fi
}

is_compressed() {
	#"file name"

	if [ `echo $1 | grep -i "\.tar\.gz$"` ] || [ `echo $1 | grep -i "\.zip$"` ]
	then
		echo 1
	else
		echo 0
	fi
}

reduce_file_name() {
	#"file name" "max size"

	if [ ${#1} -gt $2 ]
	then
		EXTENSION=`echo $1 | grep -o "\.[a-zA-Z0-9]*$"`
		echo "${1:0:$(($2 - 1 - ${#EXTENSION}))}""~""${EXTENSION}"
	else
		echo "$1"
	fi
}

reduce_string() {
	#"string" "max size"

	if [ ${#1} -gt $2 ]
	then
		echo "${1:0:$(($2 - 2))}"".."
	else
		echo "$1"
	fi
}

print_dir_file() {
	#"print string"

	echo "[34m$1[0m"
}

print_reg_file() {
	#"print string"

	echo "[39m[49m$1[0m"
}

print_exe_file() {
	#"print string"

	echo "[32m$1[0m"
}

print_comp_file() {
	#"print string"

	echo "[31m$1[0m"
}

print_file_info() {
	#"file name"

	tput sc

	tput cup 31 12
	tput ech 107
	F_NAME=`stat -c %n $1`
	echo -n `reduce_string "${F_NAME}" 107`

	tput cup 32 12
	tput ech 107
	if [ -d $1 ]
	then
		echo `print_dir_file "Directory"`
	else
		if [ `is_execute ${F_NAME}` -eq 1 ]
		then
			echo `print_exe_file "Execute file"`
		elif [ `is_compressed ${F_NAME}` -eq 1 ]
		then
			echo `print_comp_file "Compressed file"`
		else
			echo `print_reg_file "Normal file"`
		fi
	fi

	tput cup 33 12
	tput ech 107
	TEMP_STR=`stat -c %s $1`
	TEMP_STR=`convert_size ${TEMP_STR}`
	echo -n `reduce_string "${TEMP_STR}" 107`


	tput cup 34 14
	tput ech 105
	
	if [ ${F_NAME} = ".." ]
	then
		TEMP_STR=`find .. -maxdepth 1 -name $1 -printf "%Ab %Ad %AH:%AM:%.2AS %AY"`
	else
		TEMP_STR=`find . -maxdepth 1 -name $1 -printf "%Ab %Ad %AH:%AM:%.2AS %AY"`
	fi
	echo -n `reduce_string "${TEMP_STR}" 105`

	tput cup 35 13
	tput ech 106
	TEMP_STR=`stat -c %a $1`
	echo -n `reduce_string "${TEMP_STR}" 106`

	tput cup 36 16
	tput ech 103
	if [ ${PWD} = "/" ]
	then
		TEMP_STR="/`stat -c %n $1`"
	else
		TEMP_STR="${PWD}/`stat -c %n $1`"
	fi
	echo -n `reduce_string "${TEMP_STR}" 103`

	tput rc
}


get_dir_lists() {
	if [ "${PWD}" != "/" ]
	then
		echo ".."
	fi

	for FILE in `ls`
	do
		if [ -d ${FILE} ]
		then
			echo ${FILE}
		fi
	done

	#"Return 'Directory Lists'"
}

get_file_lists() {
	for FILE in `ls`
	do
		if [ -f ${FILE} ]
		then
			echo ${FILE}
		fi
	done
	
	#"Return 'File Lists'"
}

get_lists() {
	if [ "${PWD}" != "/" ]
	then
		echo ".."
	fi

	for FILE in `ls`
	do
		echo ${FILE}
	done

	#"Return 'Directory Lists'"
}


print_file_colored() {
	#"file name" "max len(value not necessary)"

	if [ $2 ]
	then
		REDUCE_FILE=`reduce_file_name "$1" "$2"`
	else
		REDUCE_FILE=$1
	fi

	if [ -d $1 ]
	then
		echo `print_dir_file ${REDUCE_FILE}`
	else
		if [ `is_execute $1` -eq 1 ]
		then
			echo `print_exe_file ${REDUCE_FILE}`
		elif [ `is_compressed $1` -eq 1 ]
		then
			echo `print_comp_file ${REDUCE_FILE}`
		else
			echo `print_reg_file ${REDUCE_FILE}`
		fi
	fi
}

print_file_single() {
	#"current print pos" "current file name" "last print pos" "last file name"

	tput sc

	X=1
	Y_1=$((1 + $1))
	Y_2=$((1 + $3))

	#print last file
	tput cup ${Y_2} $X; tput ech ${AREA_1_WIDTH}
	print_file_colored $4 ${AREA_1_WIDTH}

	#print selected file
	tput cup ${Y_1} $X; tput ech ${AREA_1_WIDTH}
	tput rev
	print_file_colored $2 ${AREA_1_WIDTH}
	tput sgr0

	tput rc
}

print_file_all() {
	#"current pos" "start print pos" "file lists"

	tput sc

	X=1
	Y=1
	POS=1
	C_POS=$1; shift
	P_POS=$1; shift
	FILE_ARR=( $@ )
	FILE_SIZE=${#FILE_ARR[@]}

	area_clear 1

	if [ ${FILE_SIZE} -gt ${AREA_HEIGHT} ]
	then
		PRINT_SIZE=${AREA_HEIGHT}
	else
		PRINT_SIZE=${FILE_SIZE}
	fi

	for (( i=$((${P_POS} - 1)); i<$((${P_POS} - 1 + ${PRINT_SIZE})); i++ ))
	do
		tput cup $(($Y + ${POS})) $X

		if [ ${FILE_SIZE} -gt ${AREA_HEIGHT} ]
		then
			if [ $((${C_POS} - ${P_POS} + 1)) -eq ${POS} ]
			then
				tput rev
			fi
		elif [ ${C_POS} -eq ${POS} ]
		then
			tput rev
		fi

		print_file_colored ${FILE_ARR[$i]} ${AREA_1_WIDTH}

		tput sgr0

		POS=$((${POS} + 1))
	done

	tput rc
}

print_file_lists() {
	#"current pos" "last pos" "start print pos" "file lists"

	C_POS=$1; shift
	L_POS=$1; shift
	P_POS=$1; shift
	FILE_ARR=( $@ )
	FILE_SIZE=${#FILE_ARR[@]}

	if [ ${C_POS} -eq ${L_POS} ]
	then
		print_file_all ${C_POS} ${P_POS} ${FILE_ARR[@]}
	else
		if [ ${FILE_SIZE} -gt ${AREA_HEIGHT} ]
		then
			if [ ${C_POS} -eq ${P_POS} ] || [ $((${C_POS} - ${AREA_HEIGHT} + 1)) -eq ${P_POS} ] 
			then
				print_file_all ${C_POS} ${P_POS} ${FILE_ARR[@]}
			else
				print_file_single $((${C_POS} - ${P_POS} + 1)) ${FILE_ARR[$((${C_POS} - 1))]} $((${L_POS} - ${P_POS} + 1)) ${FILE_ARR[$((${L_POS} - 1))]}
			fi
		else
			print_file_single $((${C_POS} - ${P_POS} + 1)) ${FILE_ARR[$((${C_POS} - 1))]} $((${L_POS} - ${P_POS} + 1)) ${FILE_ARR[$((${L_POS} - 1))]}
		fi
	fi
}

print_refresh() {
	#"Area" "current pos" "start print pos" "file lists"

	A_NUM=$1; shift
	C_POS=$1; shift
	P_POS=$1; shift
	FILE_ARR=( $@ )

	print_form
	print_file_lists ${C_POS} ${C_POS} ${P_POS} ${FILE_ARR[@]}
	print_file_info ${FILE_ARR[$((${C_POS} - 1))]}
	print_dir_info
	print_area_boundary ${A_NUM}
}

can_contents_print() {
	#"File Name"

	if [ `file -i $1 | grep -o "text"` ] && [ `is_compressed $1` -eq 0 ]
	then
		echo 1
	else
		echo 0
	fi
}

print_file_contents() {
	#"start file line" "file name"

	tput sc

	F_LINE=$1
	PRINT_LINE=1
	X=36
	N=3
	Y=1
	AREA_2_WIDTH_R=$((49 - $N))
	FILE_LINE_SIZE=( `wc -l $2` )


	#clear
	area_clear 2


	#print
	IFS=
	
	i=1
	while read line
	do
		if [ $i -lt $1 ]
		then
			i=$(($i + 1))
			continue
		fi
		if [ ${PRINT_LINE} -gt ${AREA_HEIGHT} ]
		then
			break
		fi

		FIX_LINE="`sed -e "s/[\t]/  /g" -e "s//^[/g" <<< ${line}`"

		tput cup $(($Y + ${PRINT_LINE})) $X
		echo -n "${F_LINE}"

		S_NUM=0
		while [ ${S_NUM} -le ${#FIX_LINE} ]
		do
			tput cup $(($Y + ${PRINT_LINE})) $(($X + $N))

			for ((j=${AREA_2_WIDTH_R}; ; j--))
			do
				PRINTED_LEN=`echo -n ${FIX_LINE:${S_NUM}:$j} | wc -L`

				if [ ${PRINTED_LEN} -le ${AREA_2_WIDTH_R} ]
				then
					ADD_LEN=$j
					break
				fi
			done

			echo -n "${FIX_LINE:${S_NUM}:${ADD_LEN}}"

			S_NUM=$((${S_NUM} + ${ADD_LEN}))
			PRINT_LINE=$((${PRINT_LINE} + 1))

			if [ ${PRINT_LINE} -gt ${AREA_HEIGHT} ]
			then
				break
			fi
		done

		F_LINE=$((${F_LINE} + 1))

	done < $2

	IFS=${IFS_COPY}

	tput rc
}

print_area_boundary() {
	#"area num"

	tput sc

	LINE_1=0
	LINE_2=35
	LINE_3=85
	LINE_4=119
	Y=2

	if [ $1 -eq 1 ]
	then
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $(($Y + $i)) ${LINE_1}
			echo "[95m|[0m"
		done
	else
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $(($Y + $i)) ${LINE_1}
			echo "|"
		done
	fi

	if [ $1 -eq 1 ] || [ $1 -eq 2 ]
	then
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $(($Y + $i)) ${LINE_2}
			echo "[95m|[0m"
		done
	else
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $(($Y + $i)) ${LINE_2}
			echo "|"
		done
	fi

	if [ $1 -eq 2 ] || [ $1 -eq 3 ]
	then
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $(($Y + $i)) ${LINE_3}
			echo "[95m|[0m"
		done
	else
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $(($Y + $i)) ${LINE_3}
			echo "|"
		done
	fi

	if [ $1 -eq 3 ]
	then
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $(($Y + $i)) ${LINE_4}
			echo "[95m|[0m"
		done
	else
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $(($Y + $i)) ${LINE_4}
			echo "|"
		done
	fi

	tput rc
}

area_clear() {
	#"area num"

	tput sc

	X_1=1
	X_2=36
	X_3=86
	Y_POS=2

	if [ $1 -eq 1 ]
	then
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $((${Y_POS} + $i)) ${X_1}
			tput ech ${AREA_1_WIDTH}
		done

	elif [ $1 -eq 2 ]
	then
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $((${Y_POS} + $i)) ${X_2}
			tput ech ${AREA_2_WIDTH}
		done

	elif [ $1 -eq 3 ]
	then
		for ((i=0; i<${AREA_HEIGHT}; i++))
		do
			tput cup $((${Y_POS} + $i)) ${X_3}
			tput ech ${AREA_3_WIDTH}
		done

	fi

	tput rc
}

get_tree_struct() {
	#"Directory"

	if [ "${PWD}" = "/" ]
	then
		TREE_D="/${1}"
	else
		TREE_D="${PWD}/${1}"
	fi
	TREE_S=( ${TREE_D} )

	for DSWITCH in ${T_SWITCH[@]}
	do
		if [ "${DSWITCH}" = "${TREE_D}" ]
		then
			get_dir_tree "${TREE_D}"
			break
		fi
	done

	echo ${TREE_S[@]}
	#"Return Tree Struct"
}

get_dir_tree() {
	#"Directory Path"

	for DPATH in `find ${1} -maxdepth 1 -not -path '*/\.*' | sort`
	do
		if [ ${DPATH} = $1 ]
		then
			continue
		fi

		TREE_S=( ${TREE_S[@]} ${DPATH} )

		for DSWITCH in ${T_SWITCH[@]}
		do
			if [ "${DSWITCH}" = "${DPATH}" ]
			then
				get_dir_tree "${DPATH}"
				break
			fi
		done
	done
}

get_dir_tree_D_sort() {
	#"Directory Path"

	for DPATH in `find ${1} -maxdepth 1 -type d -not -path '*/\.*' | sort`
	do
		if [ ${DPATH} = $1 ]
		then
			continue
		fi

		TREE_S=( ${TREE_S[@]} ${DPATH} )

		for DSWITCH in ${T_SWITCH[@]}
		do
			if [ "${DSWITCH}" = "${DPATH}" ]
			then
				get_dir_tree "${DPATH}"
				break
			fi
		done
	done

	TREE_S=( ${TREE_S[@]} `find ${1} -maxdepth 1 -type f -not -path '*/\.*' | sort` )
}

tree_switch() {
	#"Tree Element Value"

	TREE_VAL=$1
	TREE_INDEX=-1

	for ((i=0; i<${#T_SWITCH[@]}; i++))
	do
		if [ "${TREE_VAL}" = "${T_SWITCH[$i]}" ]
		then
			TREE_INDEX=$i
			break
		fi
	done

	if [ ${TREE_INDEX} -eq -1 ]
	then
		T_SWITCH=( ${T_SWITCH[@]} ${TREE_VAL} )
	else
		T_SWITCH=( ${T_SWITCH[@]:0:${TREE_INDEX}} ${T_SWITCH[@]:$((${TREE_INDEX} + 1))} )
	fi
}

print_tree_single() {
	#"Current Print Pos" "Current Tree Path" "Last Print Pos" "Last Tree Path"

	tput sc

	X=86
	Y_1=$((1 + $1))
	Y_2=$((1 + $3))

	#print last tree
	tput cup ${Y_2} $X; tput ech ${AREA_3_WIDTH}

	get_tree_branch "$4"
	echo -n ${TREE_BRANCH_STR:0:${AREA_3_WIDTH}}

	if [ -d "$4" ]
	then
		if [ $((${#TREE_BRANCH_STR} + 1)) -le ${AREA_3_WIDTH} ]
		then
			echo -n " "
		fi
	else
		if [ $((${#TREE_BRANCH_STR} + 1)) -le ${AREA_3_WIDTH} ]
		then
			echo -n "  "
		fi
	fi

	get_tree_name "$4"
	print_tree_colored "$4"


	#print selected tree
	tput cup ${Y_1} $X; tput ech ${AREA_3_WIDTH}

	get_tree_branch "$2"
	echo -n ${TREE_BRANCH_STR:0:${AREA_3_WIDTH}}

	if [ -d "$2" ]
	then
		if [ $((${#TREE_BRANCH_STR} + 1)) -le ${AREA_3_WIDTH} ]
		then
			echo -n " "
		fi
	else
		if [ $((${#TREE_BRANCH_STR} + 1)) -le ${AREA_3_WIDTH} ]
		then
			echo -n "  "
		fi
	fi

	tput rev
	get_tree_name "$2"
	print_tree_colored "$2"
	tput sgr0

	tput rc
}

print_tree_all() {
	#"current pos" "start print pos"

	tput sc

	X=86
	Y=1
	POS=1
	C_POS=$1
	P_POS=$2

	area_clear 3

	if [ ${T_SIZE} -gt ${AREA_HEIGHT} ]
	then
		PRINT_SIZE=${AREA_HEIGHT}
	else
		PRINT_SIZE=${T_SIZE}
	fi

	for (( i=$((${P_POS} - 1)); i<$((${P_POS} - 1 + ${PRINT_SIZE})); i++ ))
	do
		tput cup $(($Y + ${POS})) $X

		get_tree_branch "${T_STRUCT[$i]}"
		echo -n ${TREE_BRANCH_STR:0:${AREA_3_WIDTH}}

		if [ -d "${T_STRUCT[$i]}" ]
		then
			if [ $((${#TREE_BRANCH_STR} + 1)) -le ${AREA_3_WIDTH} ]
			then
				echo -n " "
			fi
		else
			if [ $((${#TREE_BRANCH_STR} + 1)) -le ${AREA_3_WIDTH} ]
			then
				echo -n "  "
			fi
		fi

		if [ ${T_SIZE} -gt ${AREA_HEIGHT} ]
		then
			if [ $((${C_POS} - ${P_POS} + 1)) -eq ${POS} ]
			then
				tput rev
			fi
		elif [ ${C_POS} -eq ${POS} ]
		then
			tput rev
		fi

		get_tree_name "${T_STRUCT[$i]}"
		print_tree_colored "${T_STRUCT[$i]}"

		tput sgr0

		POS=$((${POS} + 1))
	done

	tput rc
}

print_tree() {
	#"current pos" "last pos" "start print pos"

	C_POS=$1
	L_POS=$2
	P_POS=$3

	TREE_BRANCH_STR=""
	TREE_NAME=""

	if [ ${C_POS} -eq ${L_POS} ]
	then
		print_tree_all ${C_POS} ${P_POS}
	else
		if [ ${T_SIZE} -gt ${AREA_HEIGHT} ]
		then
			if [ ${C_POS} -eq ${P_POS} ] || [ $((${C_POS} - ${AREA_HEIGHT} + 1)) -eq ${P_POS} ] 
			then
				print_tree_all ${C_POS} ${P_POS}
			else
				print_tree_single $((${C_POS} - ${P_POS} + 1)) ${T_STRUCT[$((${C_POS} - 1))]} $((${L_POS} - ${P_POS} + 1)) ${T_STRUCT[$((${L_POS} - 1))]}
			fi
		else
			print_tree_single $((${C_POS} - ${P_POS} + 1)) ${T_STRUCT[$((${C_POS} - 1))]} $((${L_POS} - ${P_POS} + 1)) ${T_STRUCT[$((${L_POS} - 1))]}
		fi
	fi
}

get_tree_name() {
	#"File Path"

	IFS='/'
	P_G=( $1 )
	P_G_NAME=${P_G[$((${#P_G[@]} - 1))]}
	IFS=${IFS_COPY}

	TREE_NAME=${P_G_NAME}
}

get_tree_branch() {
	#"File Path"

	IFS='/'

	#Path : Standard
	P_S=( ${T_STRUCT[0]} )
	P_S_NAME=${P_S[$((${#P_S[@]} - 1))]}
	#Path : Get
	P_G=( $1 )
	P_G_NAME=${P_G[$((${#P_G[@]} - 1))]}

	for (( P_G_I=0; P_G_I<${#P_G[@]}; P_G_I++ ))
	do
		if [ "${P_S_NAME}" = "${P_G[${P_G_I}]}" ]
		then
			INDEX_S=${P_G_I}
			break
		fi
	done

	INDEX_DIFF=$((${#P_G[@]} - 1 - ${INDEX_S}))

	TREE_BRANCH_STR=
	for (( D_I=0; D_I<${INDEX_DIFF}; D_I++ ))
	do
		TREE_BRANCH_STR+="...."
	done

	IFS=${IFS_COPY}

	if [ -d "$1" ]
	then
		for SW in ${T_SWITCH[@]}
		do
			if [ "${SW}" = "${1}" ]
			then
				TREE_BRANCH_STR+=" -"
				return
			fi
		done

		TREE_BRANCH_STR+=" +"
	fi
}

print_tree_colored() {
	#"File Path"

	T_B_LEN=${#TREE_BRANCH_STR}
	if [ -d "$1" ]
	then
		T_B_LEN=$((${T_B_LEN} + 1))
	else
		T_B_LEN=$((${T_B_LEN} + 2))
	fi

	if [ ${T_B_LEN} -gt ${AREA_3_WIDTH} ]
	then
		return
	fi

	REDUCE_FILE=`reduce_file_name "${TREE_NAME}" $((${AREA_3_WIDTH} - ${T_B_LEN}))`

	if [ -d "$1" ]
	then
		echo `print_dir_file "${REDUCE_FILE}"`
	else
		if [ -x $1 ]
		then
			echo `print_exe_file "${REDUCE_FILE}"`
		elif [ `is_compressed "${TREE_NAME}"` -eq 1 ]
		then
			echo `print_comp_file "${REDUCE_FILE}"`
		else
			echo `print_reg_file "${REDUCE_FILE}"`
		fi
	fi
}



###############start###############

tput smcup
tput civis

cd ${HOME}

DIR=${PWD}
#LIST_ARR=( `get_dir_lists` `get_file_lists` )
LIST_ARR=( `get_lists` )
L_SIZE=${#LIST_ARR[@]}
HEIGHT=28
CUR_POS=1
LAST_POS=1
PRINT_POS=1

IS_CONTENTS_PRINTED=0
CONTENT_LINE=1
CONTENT_LINE_SIZE=1

AREA=1
AREA_1_WIDTH=34
AREA_2_WIDTH=49
AREA_3_WIDTH=33
AREA_HEIGHT=28

T_STD_DIR=""
T_STRUCT=( )
T_SWITCH=( )
T_SIZE=0
T_CUR=1
T_L_POS=1
T_P_POS=1
IS_TREE_PRINTED=0


IFS_COPY=${IFS}


print_refresh ${AREA} ${CUR_POS} ${PRINT_POS} ${LIST_ARR[@]}


while true
do
	IFS=
	read -sN1 KEY_1
	IFS=${IFS_COPY}

	if [ "${KEY_1}" = "" ]
	then
		read -sN2 KEY_2

		if [ "${KEY_2}" = "[A" ]
		then
			if [ ${AREA} -eq 1 ]
			then
				if [ ${CUR_POS} -eq 1 ]
				then
					LAST_POS=${CUR_POS}
					CUR_POS=${L_SIZE}
					if [ ${L_SIZE} -gt ${HEIGHT} ]
					then
						PRINT_POS=$((${L_SIZE} - ${HEIGHT} + 1))
					fi
				else
					LAST_POS=${CUR_POS}
					CUR_POS=$((${CUR_POS} - 1))
					if [ ${L_SIZE} -gt ${HEIGHT} ] && [ ${PRINT_POS} -gt ${CUR_POS} ]
					then
						PRINT_POS=${CUR_POS}
					fi
				fi

				if [ ${IS_CONTENTS_PRINTED} -eq 1 ]
				then
					area_clear 2
					IS_CONTENTS_PRINTED=0
				fi
				print_file_lists ${CUR_POS} ${LAST_POS} ${PRINT_POS} ${LIST_ARR[@]}
				print_file_info ${LIST_ARR[$((${CUR_POS} - 1))]}

			elif [ ${AREA} -eq 2 ]
			then
				if [ ${IS_CONTENTS_PRINTED} -eq 0 ]
				then
					continue
				fi

				if [ ${CONTENT_LINE} -eq 1 ]
				then
					CONTENT_LINE=${CONTENT_LINE_SIZE}
					print_file_contents ${CONTENT_LINE} ${LIST_ARR[$((${CUR_POS} - 1))]}
				else
					CONTENT_LINE=$((${CONTENT_LINE} - 1))
					print_file_contents ${CONTENT_LINE} ${LIST_ARR[$((${CUR_POS} - 1))]}
				fi

			elif [ ${AREA} -eq 3 ]
			then
				if [ ${IS_TREE_PRINTED} -eq 0 ]
				then
					continue
				fi

				if [ ${T_CUR} -eq 1 ]
				then
					T_L_POS=${T_CUR}
					T_CUR=${T_SIZE}
					if [ ${T_SIZE} -gt ${HEIGHT} ]
					then
						T_P_POS=$((${T_SIZE} - ${HEIGHT} + 1))
					fi
				else
					T_L_POS=${T_CUR}
					T_CUR=$((${T_CUR} - 1))
					if [ ${T_SIZE} -gt ${HEIGHT} ] && [ ${T_P_POS} -gt ${T_CUR} ]
					then
						T_P_POS=${T_CUR}
					fi
				fi

				print_tree ${T_CUR} ${T_L_POS} ${T_P_POS}
			fi

		elif [ "${KEY_2}" = "[B" ]
		then
			if [ ${AREA} -eq 1 ]
			then
				if [ ${CUR_POS} -eq ${L_SIZE} ]
				then
					LAST_POS=${CUR_POS}
					CUR_POS=1
					PRINT_POS=1
				else
					LAST_POS=${CUR_POS}
					CUR_POS=$((${CUR_POS} + 1))
					if [ ${L_SIZE} -gt ${HEIGHT} ] && [ ${PRINT_POS} -lt $((${CUR_POS} - ${HEIGHT} + 1)) ]
					then
						PRINT_POS=$((${CUR_POS} - ${HEIGHT} + 1))
					fi
				fi

				if [ ${IS_CONTENTS_PRINTED} -eq 1 ]
				then
					area_clear 2
					IS_CONTENTS_PRINTED=0
				fi
				print_file_lists ${CUR_POS} ${LAST_POS} ${PRINT_POS} ${LIST_ARR[@]}
				print_file_info ${LIST_ARR[$((${CUR_POS} - 1))]}

			elif [ ${AREA} -eq 2 ]
			then
				if [ ${IS_CONTENTS_PRINTED} -eq 0 ]
				then
					continue
				fi

				if [ ${CONTENT_LINE} -eq ${CONTENT_LINE_SIZE} ]
				then
					CONTENT_LINE=1
					print_file_contents ${CONTENT_LINE} ${LIST_ARR[$((${CUR_POS} - 1))]}
				else
					CONTENT_LINE=$((${CONTENT_LINE} + 1))
					print_file_contents ${CONTENT_LINE} ${LIST_ARR[$((${CUR_POS} - 1))]}
				fi

			elif [ ${AREA} -eq 3 ]
			then
				if [ ${IS_TREE_PRINTED} -eq 0 ]
				then
					continue
				fi

				if [ ${T_CUR} -eq ${T_SIZE} ]
				then
					T_L_POS=${T_CUR}
					T_CUR=1
					T_P_POS=1
				else
					T_L_POS=${T_CUR}
					T_CUR=$((${T_CUR} + 1))
					if [ ${T_SIZE} -gt ${HEIGHT} ] && [ ${T_P_POS} -lt $((${T_CUR} - ${HEIGHT} + 1)) ]
					then
						T_P_POS=$((${T_CUR} - ${HEIGHT} + 1))
					fi
				fi

				print_tree ${T_CUR} ${T_L_POS} ${T_P_POS}
			fi

		elif [ "${KEY_2}" = "[C" ]
		then
			if [ ${AREA} -eq 3 ]
			then
				AREA=1
			else
				AREA=$((${AREA} + 1))
			fi

			print_area_boundary ${AREA}

		elif [ "${KEY_2}" = "[D" ]
		then
			if [ ${AREA} -eq 1 ]
			then
				AREA=3
			else
				AREA=$((${AREA} - 1))
			fi

			print_area_boundary ${AREA}
		fi

	elif [ ${AREA} -eq 1 ]
	then
		if [ "${KEY_1}" = $'\x0A' ]
		then
			if [ -d ${LIST_ARR[$((${CUR_POS} - 1))]} ]
			then
				cd ${LIST_ARR[$((${CUR_POS} - 1))]}

				DIR=${PWD}
				#LIST_ARR=( `get_dir_lists` `get_file_lists` )
				LIST_ARR=( `get_lists` )
				L_SIZE=${#LIST_ARR[@]}
				CUR_POS=1
				LAST_POS=1
				PRINT_POS=1

				print_refresh ${AREA} ${CUR_POS} ${PRINT_POS} ${LIST_ARR[@]}
				IS_CONTENTS_PRINTED=0
				IS_TREE_PRINTED=0

			elif [ `can_contents_print ${LIST_ARR[$((${CUR_POS} - 1))]}` -eq 1 ]
			then
				IS_CONTENTS_PRINTED=1
				CONTENT_LINE=1
				CONTENT_LINE_SIZE=( `wc -l ${LIST_ARR[$((${CUR_POS} - 1))]}` )
				print_file_contents ${CONTENT_LINE} ${LIST_ARR[$((${CUR_POS} - 1))]}
			fi

		elif [ "${KEY_1}" = "t" ] && [ -d "${LIST_ARR[$((${CUR_POS} - 1))]}" ] && [ ".." != "${LIST_ARR[$((${CUR_POS} - 1))]}" ]
		then
			AREA=3
			print_area_boundary ${AREA}
			T_STD_DIR=${LIST_ARR[$((${CUR_POS} - 1))]}
			T_SWITCH=( "${PWD}/${LIST_ARR[$((${CUR_POS} - 1))]}" )
			T_STRUCT=( `get_tree_struct "${T_STD_DIR}"` )
			T_SIZE=${#T_STRUCT[@]}

			T_CUR=1
			T_L_POS=1
			T_P_POS=1
			IS_TREE_PRINTED=1
			print_tree ${T_CUR} ${T_L_POS} ${T_P_POS}
		fi

	elif [ ${AREA} -eq 3 ]
	then
		if [ "${KEY_1}" = $'\x20' ] && [ -d ${T_STRUCT[$((${T_CUR} - 1))]} ] && [ ${IS_TREE_PRINTED} -eq 1 ]
		then
			tree_switch ${T_STRUCT[$((${T_CUR} - 1))]}
			T_STRUCT=( `get_tree_struct "${T_STD_DIR}"` )
			T_SIZE=${#T_STRUCT[@]}

			T_L_POS=${T_CUR}
			print_tree ${T_CUR} ${T_L_POS} ${T_P_POS}

		elif [ "${KEY_1}" = "r" ]
		then
			AREA=1
			print_area_boundary ${AREA}
		fi
	fi
done


tput cnorm
tput rmcup
