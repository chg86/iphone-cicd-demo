# MTAutoPackage - iOS项目自动打包脚本

## 证书

安装证书


## 脚本执行

1 执行脚本后按需求输入选择打包版本
2 如果执行脚本时出现如下错误是因为文件权限不足，只需对其授权即可

## 打包脚本核心内容展示


# 先组装路径 archive_path、ipa_path ，用于导出 ipa 和 上传
```
archive_path="${temp_path}/${ipa_dir}/${pro_name}.xcarchive"
ipa_path="${temp_path}/${ipa_dir}/${pro_name}.ipa"
```

# Clean操作
```
xcodebuild clean -${pro_clean} ${pro_full_name} -scheme ${pro_name} -configuration ${pro_environ}
judgementLastIsSuccsess $? "Clean"
```

# Archive操作
```
xcodebuild archive -${pro_clean} ${pro_full_name} -scheme ${pro_name} -archivePath ${archive_path}
judgementLastIsSuccsess $? "Archive"
```

# 导出IPA文件操作
```
xcodebuild -exportArchive -archivePath ${archive_path} -exportOptionsPlist ${plist_path} -exportPath ${temp_path}/${ipa_dir}
judgementLastIsSuccsess $? "导出IPA文件"
```

# 删除 xcarchive 包
```
rm -r ${archive_path}
```