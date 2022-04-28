import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/config/config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_demo/utils/dialog.dart';

class imageUploadWidget extends StatefulWidget {
  List<XFile> _imageFileList = List.empty(growable: true);

  List<XFile> get imageList => _imageFileList;

  int imgNum = 6;

  imageUploadWidget({Key? key, required this.imgNum}) : super(key: key);

  @override
  _imageUploadWidgetState createState() => _imageUploadWidgetState();
}

class _imageUploadWidgetState extends State<imageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  int maxFileCount = 6; //图片数量
  dynamic _pickImageError;
  int _bigImageIndex = 0; //放大图片下标
  bool _bigImageVisibility = false; //预览图

  @override
  void initState() {
    super.initState();
    setState(() {
      maxFileCount = widget.imgNum;
    });
  }

  int getImageCount() {
    if (widget._imageFileList.length < maxFileCount) {
      return widget._imageFileList.length + 1;
    } else {
      return widget._imageFileList.length;
    }
  }

  Widget _handlePreview() {
    return _previewImages();
  }

  Widget _previewImages() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(left: 22.0.w, right: 22.0.w, top: 10.0.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, //一行3个
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        if (widget._imageFileList.length < maxFileCount) {
          if (index < widget._imageFileList.length) {
            return Container(
              margin: EdgeInsets.all(5.0.sp),
              child: Stack(
                //stack布局，为了给图片加一个删除的按钮
                alignment: Alignment.center,
                children: [
                  Positioned(
                    child: Container(
                      child: GestureDetector(
                        child: Image.file(
                          File(widget._imageFileList[index].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0.r),
                        border: Border.all(
                          //设置边框
                          color: Colors.white,
                          width: 1.0.w,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    child: GestureDetector(
                      child: SizedBox(
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () => _removeImage(index),
                    ),
                  )
                ],
              ),
            );
          } else {
            //显示添加符号
            return Container(
              margin: EdgeInsets.all(5.0.sp),
              child: GestureDetector(
                //手势包含添加按钮 实现点击进行选择图片
                child: Icon(Icons.add_a_photo),
                onTap: () => _onImageButtonPressed(
                  //执行打开相册
                  ImageSource.gallery,
                  context: context,
                  imageQuality: 40, //图片压缩
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0.r),
                border: Border.all(
                  //设置边框
                  color: Colors.black,
                  width: 1.0.w,
                ),
              ),
            );
          }
        }
        return Container(
          margin: EdgeInsets.all(5.0.sp),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: GestureDetector(
                  child: Image.file(
                    File(widget._imageFileList[index].path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                child: GestureDetector(
                  child: SizedBox(
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () => _removeImage(index),
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.0.r),
            border: Border.all(
              //设置边框
              color: Colors.white,
              width: 1.0.w,
            ),
          ),
        );
      },
      itemCount: getImageCount(),
    );
  }

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context,
      double? maxHeight,
      double? maxWidth,
      int? imageQuality}) async {
    try {
      final pickedFileList = await _picker.pickMultiImage(
        maxHeight: maxWidth,
        maxWidth: maxWidth,
        imageQuality: imageQuality,
      );
      setState(() {
        if (widget._imageFileList.length < maxFileCount) {
          //小于最大数量
          if ((widget._imageFileList.length + (pickedFileList?.length ?? 0)) <=
              maxFileCount) {
            //加上新选中的不超过最大数量
            pickedFileList!.forEach((element) async {
              int size = await element.length();
              if(size > Config.goodsN * 1024 * 1024) {
                showToast("单个文件不能大于${Config.goodsN}MB");
                return ;
              }
              widget._imageFileList.add(element);
            });
          } else {
            //否则报错
            showToast("超过最大数量，自动移除多余图片");
            int avaliableCount = maxFileCount - widget._imageFileList.length;
            for (int i = 0; i < avaliableCount; i++) {
              widget._imageFileList.add(pickedFileList![i]);
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  // 移除图片
  void _removeImage(int index) {
    setState(() {
      widget._imageFileList.removeAt(index);
    });
  }

  // //双击小图获得需要放大的图片的下标
  // void showBigImage(int index) {
  //   setState(() {
  //     _bigImageIndex = index;
  //     _bigImageVisibility = true;
  //   });
  // }

  // //通过大图的双击事件 隐藏大图
  // void hiddenBigImage() {
  //   setState(() {
  //     _bigImageVisibility = false;
  //   });
  // }

  // //展示大图
  // Widget? displayBigImage() {
  //   if (widget._imageFileList.length > _bigImageIndex) {
  //     return Image.file(
  //       File(widget._imageFileList[_bigImageIndex].path),
  //       fit: BoxFit.fill,
  //     );
  //   } else {
  //     return null;
  //   }
  // }

  //图片上传
  _uploadImage() async {
    List<dynamic> _imgListUpload = [];
    widget._imageFileList.forEach((element) {
      _imgListUpload.add(
          MultipartFile.fromFileSync(element.path, filename: element.name));
    });
    var formData = FormData.fromMap({
      'files': _imgListUpload,
    });
    // try {
    //   var response = uploadModel(formData);

    // } catch(e) {

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _handlePreview(),
    );
  }
}
