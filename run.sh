host=${1}
# homeFolder="/home/vt_admin"
homeFolder="/home/mrd09/knowledge/ssh_script"

numberOfGrep=`cat "${homeFolder}/password" | awk '{print $1}' | grep ${host} | wc -l`
if [ ${numberOfGrep} -gt 1 ]
then
	resultArray=(`cat "${homeFolder}/password" | awk '{print $1}' | grep ${host}`)
	for element in $(seq 0 $((${#resultArray[@]} - 1)))
	do
		echo [$(($element + 1))]: ${resultArray[$element]}
	done
	printf "[+]Select an OPTION [Number] and press [Enter]: "
	read option
	re='^[0-9]+$'
	if ! [[ $option =~ $re ]] ; then
		echo "Error: Not a number"
		exit 1
	else
		if [[ ( $option -gt $((${#resultArray[@]} + 1)) ) || ( ${option} -lt 0 ) ]]; then
			echo "Error: Option not Existed."
			exit 1
		else
			result=${resultArray[$(($option - 1))]}	
		fi
	fi
elif [[ ${numberOfGrep} -eq 0 ]]; then
	echo "Host NOT existed."
	exit 1
else
	result=`cat "${homeFolder}/password" | awk '{print $1}' | grep ${host}`
fi

combination=`grep -w ${result} "${homeFolder}/password"`
ip=`echo ${combination} | awk '{print $2}'`
user=`echo ${combination} | awk '{print $3}'`
password=`echo ${combination} | awk '{print $4}'`

echo "HOST: ${result}"
echo "IP: ${ip}"
# echo "User: ${user}"
# echo "Password: ${password}"

# if [[ ${#password} == 0 ]]
# then
# 	echo -n "No password.Please Enter Manually: "
# 	read addPassword
# 	echo ${addPassword}
# 	echo "Save password."
# 	newCombination=`echo "${combination} ${addPassword}"`
# 	password=`echo ${addPassword}`
# 	sed -i "s/${combination}/${newCombination}/" ${homeFolder}/sshScript/password
# 	combination=`echo ${newCombination}`
# fi

# Start SSH Session
${homeFolder}/sshScript.exp ${ip} ${user} ${password}

# If SSH not successfully, Delete password
# if [[ $? == 1 ]]
# then
# 	printf "Password NOT Correct. Deleting Password..."
# 	removedPassword=`echo ${combination} | rev | cut -d" " -f 2- | rev | sed -e "s/[[:space:]]*$//"`
# 	sed -i "s/${combination}/${removedPassword}/g" ${homeFolder}/sshScript/password
# 	printf "DONE.\n"
# fi