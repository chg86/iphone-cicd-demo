#!/bin/bash
# ⚠️默认 Release 版，也可配置为 Debug
pro_environ=Release
# 项目路径
proj_dir=$(dirname `pwd`/$0)

pro_path="${proj_dir}/MTPackerDemo/MTPackerDemo.xcodeproj"

############################ 参数配置 ###################################

# 截取项目全称 （如：MTPackDemo.xcworkspace --> 项目名称、项目后缀）
pro_full_name=${pro_path##*/}
# 分割得 项目名称、项目后缀
pro_array=(${pro_full_name//./ })
pro_name=${pro_array[0]}
pro_suffix=${pro_array[1]}
# 项目文件夹路径
pro_path=${pro_path%/*}

# 判断项目全称是否配置正确
if [ "${pro_suffix}" != "xcworkspace" ] && [ "${pro_suffix}" != "xcodeproj" ]; then
echo "${CWARNING}⚠️项目名称配置错误，请正确配置project_full_name，如：MTPackDemo.xcworkspace 或 MTPackDemo.xcodeproj类型${CEND}"
exit
fi

# 打包导出类型(根据 plist 文件决定)
plist_name=""

while :; do
  printf "
选择你的打包版本类型：
   ${CMSG}1${CEND}.Developers(开发版)
   ${CMSG}q${CEND}.退出打包脚本\n
"
  read -p "请输入打包类型: " number
  if [[ ! ${number} =~ ^[1-4,q]$ ]]; then
    echo "${CFAILURE}⚠️输入错误! 只允许输入 1 ~ 4 和 q${CEND}"
  else
    case "$number" in
        1)
          plist_name="DevelopmentExportOptions.plist"
          break
          ;;
        q)
          exit
          ;;
    esac
  fi
done

# 根据需求判断上一步是否执行成功，传入执行结果：$? "执行步骤名"
judgementLastIsSuccsess() {
    if [ $1 -eq 0 ]; then
    echo -e "\n✅ $2 操 作 成 功 ! \n"
    else
    echo -e "\n❌ $2操作失败，终止脚本 ! \n"
    exit
    fi
}

# 时间转换函数（秒转分钟）
timeTransformation()
{
    if [ $1 -le 0 ]; then
    echo "============ ⚠️请检查项目是否能正常手动打包并导出ipa文件 ======="
    exit
    fi
    if [ $1 -gt 59 ]; then
    t_min=$[$1 / 60]
    t_second=$[$1 % 60]
    echo "============ 本次$2用时：${t_min}分${t_second}秒 ======="
    else
    echo "============ 本次$2用时：$1秒 ======="
    fi
}

# 打包开始时间（用于计算打包脚本执行时间）
begin_time=$(date +%s)
# 获取系统时间
date_string=`date +"%Y-%m-%d~%H.%M.%S"`

# 获取脚本当前所在目录(即上级目录绝对路径)
root_dir=$(cd "$(dirname "$0")"; pwd)
# IPA 文件导出时使用的 plist 文件路径
plist_path="${root_dir}/ExportOptions/${plist_name}"

# 切换到当前脚本的工作目录
cd ${root_dir}

# 所有打包文件导出时的临时存放目录（IPA、Achieve）
temp_path="${root_dir}/ExportIPAFile"
if [ ! -d ${temp_path} ]; then
   mkdir -p ${temp_path}
fi

# 切换到 temp_path 目录去创建存放 Archive 和 IPA 的文件夹
cd ${temp_path}
ipa_dir="${pro_name}${date_string}"
mkdir ${ipa_dir}

# 切换到项目根目录开始打包操作
cd "${pro_path}"

echo "============ ${pro_name} 打包开始 ======="

# 如果没有使用cocoapods 反之if会处理
pro_clean=project
if [ ${pro_suffix} == "xcworkspace" ]; then
pro_clean=workspace
fi

# 先组装 archive_path、ipa_path，用于导出 ipa 和 上传
archive_path="${temp_path}/${ipa_dir}/${pro_name}.xcarchive"
ipa_path="${temp_path}/${ipa_dir}/${pro_name}.ipa"

# Clean操作
xcodebuild clean -${pro_clean} ${pro_full_name} -scheme ${pro_name} -configuration ${pro_environ}
judgementLastIsSuccsess $? "Clean"

# Archive操作
xcodebuild archive -${pro_clean} ${pro_full_name} -scheme ${pro_name} -archivePath ${archive_path}
judgementLastIsSuccsess $? "Archive"

# 导出IPA文件操作
xcodebuild -exportArchive -archivePath ${archive_path} -exportPath ${temp_path}/${ipa_dir} -exportOptionsPlist ${plist_path}
judgementLastIsSuccsess $? "导出IPA文件"

# 删除 xcarchive 包
rm -r ${archive_path}

# 打包结束时间
end_time=$(date +%s)
# 计算打包时间(秒：s)
cost_time=$[${end_time} - ${begin_time}]
# 调用时间转换函数
timeTransformation ${cost_time} "打包"

echo "============ ${pro_name} 自动打包完成 ======="

# 打开 当前的 ipa 存放文件夹
open ${temp_path}/${ipa_dir}




