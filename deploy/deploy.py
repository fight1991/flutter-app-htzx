# !/usr/bin/python
# -*- coding: utf-8 -*-
import json
import sys
import getopt
import os
import urllib.parse
import urllib.request
import base64
import hashlib

from PIL import Image, ImageDraw, ImageFont
from obs import *
from MyQR import myqr


def make_bucket_client(AK=None, SK=None, bucket="ht-ht-app-test", zone="cn-east-3"):
    if AK is None or SK is None or bucket is None or zone is None:
        print("make_bucket_client failed, AK、SK、bucket、zone has None")
        return None

    server = "https://obs.{0}.myhuaweicloud.com".format(zone)
    url_visit_prefix = "https://{0}.obs-website.{1}.myhuaweicloud.com/".format(bucket, zone)

    # create ObsClient instance
    obsClient = ObsClient(access_key_id=AK, secret_access_key=SK, server=server)
    bucket_client = obsClient.bucketClient(bucket)
    print("Obs authorization, server:{0}, bucketName:{1}, AK:{2}".format(server, bucket, AK))
    return bucket_client, url_visit_prefix


def listdir(path, list_name):  # 传入存储的list
    for file in os.listdir(path):
        file_path = os.path.join(path, file)
        if os.path.isdir(file_path):
            listdir(file_path, list_name)
        else:
            list_name.append(file_path)


def upload_file(bucket_client, file_path, save_path, force=False):
    print("upload file start...")
    print(file_path + " => ", save_path)

    if file_path is None or save_path is None:
        print("upload file failed. file_path is None or save_path is None.")
        return None
    if not os.path.exists(file_path):
        print("upload file failed. file_path not exists.")
        return None

    files_path_array = []
    upload_path_array = []
    if os.path.isdir(file_path):
        listdir(file_path, files_path_array)
        separator = "" if save_path.endswith("/") else "/"
        for item in files_path_array:
            upload_path_array.append(save_path + separator + item.replace(file_path, ""))
    else:
        files_path_array.append(file_path)
        if save_path.endswith("/"):
            upload_path_array.append(save_path + file_path.split("/")[-1])
        else:
            upload_path_array.append(save_path)

    files_count = len(files_path_array)
    print("find files:", files_count)
    for i in range(0, files_count):
        print(i, ":", files_path_array[i], "=>", upload_path_array[i])

    if force is False:
        resp = bucket_client.listObjects(prefix=save_path, marker=None, max_keys=10, delimiter=None)
        if resp.status != 200:
            print('upload file failed. bucketClient.listObjects fail, status:', resp.status)
            return None

        save_file_path_array = []
        i = 0
        if resp.body:
            print("list objects:", len(resp.body.contents))
            for content in resp.body.contents:
                print(i, '=>',
                      'key:', content.key,
                      ',lastModified:', content.lastModified,
                      ',etag:', content.etag,
                      ',size:', content.size,
                      ',storageClass:', content.storageClass,
                      ',isAppendable:', content.isAppendable)
                save_file_path_array.append(content.key)
                i += 1

        has_exist = False
        for item in upload_path_array:
            if item in save_file_path_array:
                has_exist = True
                print('{0} has exist'.format(item))

        if has_exist:
            print('upload filed, has_exist, please use --force.')
            return None

    else:
        print('upload file will be overlap with --force')

    for i in range(0, files_count):
        file_item_path = files_path_array[i]
        upload_item_path = upload_path_array[i]
        content_type = get_content_type(file_item_path)
        fileHeaders = None
        if content_type is not None:
            fileHeaders = PutObjectHeader(contentType=content_type)
        resp = bucket_client.putFile(objectKey=upload_item_path, file_path=file_item_path, headers=fileHeaders)
        if resp.status != 200:
            print('upload file failed. uploadFile fail, status:', resp.status, ", file:", upload_item_path)
            return None

    print("upload file success:", len(upload_path_array), "/", len(files_path_array))
    return upload_path_array


def make_qrcode(words, save_dir, save_name=None, picture=None):
    # 普通二维码：
    # version:-v 控制边长，范围是1至40，数字越大边长越大
    # level: -l 控制纠错水平，范围是L、M、Q、H，从左到右依次升高
    # save_name: -n 控制文件名，格式可以是 .jpg、.png、.bmp、.gif
    # save_dir: -d 控制文件存放的位置
    # 艺术二维码：
    # picture: 参数 -p 用来将QR二维码图像与一张同目录下的图片相结合，产生一张黑白图片。
    # colorized: 参数 -c 可以使产生的图片由黑白变为彩色的。
    # contrast: 参数 -con 用以调节图片的对比度，1.0 表示原始图片，更小的值表示更低对比度，更大反之。默认为1.0。
    # brightness: 参数 -bri 用来调节图片的亮度，其余用法和取值与 -con 相同。
    # 动态GIF二维码:
    file_name = "qrcode.png"
    if picture is not None:
        temp = picture.lower()
        if temp.endswith(".gif"):
            file_name = "qrcode.gif"
        elif temp.endswith(".jpg"):
            file_name = "qrcode.png"
        elif temp.endswith(".png"):
            file_name = "qrcode.png"
        elif temp.endswith(".bmp"):
            file_name = "qrcode.png"
        else:
            picture = None
    file_name = file_name if save_name is None else save_name
    print("start make Qrcode... \npicture:", picture, "\nsave_dir:", save_dir, "\nsave_name:", file_name)
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)

    version, level, qr_name = myqr.run(
        words,
        version=1,
        level='H',
        picture=picture,
        colorized=True,
        contrast=1.0,
        brightness=1.0,
        save_name=file_name,
        save_dir=save_dir,
    )
    return qr_name


def get_content_type(filename):
    contentType = None
    temp = filename.lower()
    if temp.endswith(".txt"):
        contentType = "text/plain"
    elif temp.endswith(".xml"):
        contentType = "text/xml"
    elif temp.endswith(".html"):
        contentType = "text/html"
    elif temp.endswith(".htm"):
        contentType = "text/html"
    elif temp.endswith(".xhtml"):
        contentType = "text/html"
    elif temp.endswith(".svg"):
        contentType = "text/xml"
    elif temp.endswith(".css"):
        contentType = "text/css"
    elif temp.endswith(".js"):
        contentType = "application/x-javascript"
    elif temp.endswith(".pdf"):
        contentType = "application/pdf"

    elif temp.endswith(".png"):
        contentType = "image/png"
    elif temp.endswith(".jpg"):
        contentType = "image/jpeg"
    elif temp.endswith(".jpeg"):
        contentType = "image/jpeg"
    elif temp.endswith(".gif"):
        contentType = "image/gif"
    elif temp.endswith(".tif"):
        contentType = "image/tiff"
    elif temp.endswith(".tiff"):
        contentType = "image/tiff"
    elif temp.endswith(".fax"):
        contentType = "image/fax"
    elif temp.endswith(".ico"):
        contentType = "image/x-icon"
    elif temp.endswith(".wbmp"):
        contentType = "image/vnd.wap.wbmp"

    elif temp.endswith(".apk"):
        contentType = "application/vnd.android.package-archive"
    elif temp.endswith(".ipa"):
        contentType = "application/vnd.iphone"

    print("contentType:", contentType, ", filename:", filename)
    return contentType


def get_font_file(font_name=None):
    font_path = None
    if font_name is None or os.path.exists(font_name) is False:
        script_dir = os.path.dirname(os.path.realpath(__file__))
        for root, dirs, files in os.walk(script_dir):
            for file in files:
                if file.endswith(".ttf"):
                    font_path = script_dir + "/" + file
                    break
    return font_path


def split_text_by_font(text, max_width, text_font, split_array):
    if text is None: return False
    count = len(text)
    if count < 1: return False
    offset = 0
    for i in range(0, count):
        if text_font.getsize(text[0:i])[0] > max_width:
            split_array.append(text[0:i - 1])
            split_text_by_font(text[i:], max_width, text_font, split_array)
            return True
    split_array.append(text)
    return True


def make_image_for_text(text='default',
                        output_dir=None,
                        width=512,
                        padding=10,
                        line_height=10,
                        title_font_size=50,
                        text_font_size=30,
                        font_name=None):
    if text is None or len(text) < 1: return None

    font_path = get_font_file(font_name=font_name)
    if font_path is None:
        print("make_image filed, can not find font")
        return None

    print("make image start...")
    print("font_path:", font_path)

    line_array = text.split("\n")
    print("text count lines:", len(line_array))

    title = line_array[0]
    titleFont = ImageFont.truetype(font_path, size=title_font_size)
    titleSize = titleFont.getsize("她")
    split_title_array = []
    split_text_by_font(title, (width - 2 * padding), titleFont, split_title_array)
    titleLineCount = len(split_title_array)

    text_array = line_array[1:]
    split_text_array = []
    textFont = ImageFont.truetype(font_path, size=text_font_size)
    textSize = textFont.getsize("她")
    for item in text_array:
        if item is None or len(item) < 1: split_text_array.append(" ")
        split_text_by_font(item, (width - 2 * padding), textFont, split_text_array)

    textLineCount = len(split_text_array)

    height = padding * 2 + (titleSize[1] + line_height) * titleLineCount + (textSize[1] + line_height) * textLineCount

    print("width:", width, ",height:", height)
    new_img = Image.new('RGBA', (width, height), (255, 255, 255, 255))

    draw = ImageDraw.Draw(new_img)

    # draw title
    print("title line count:", titleLineCount)
    titleColor = (0, 0, 0)
    for i in range(0, titleLineCount):
        x = padding
        y = padding + titleSize[1] * i + i * line_height
        # print("draw title:", split_title_array[i], ",x:", x, ",y:", y)
        draw.text((x, y), split_title_array[i], font=titleFont, fill=titleColor)

    # draw text
    print("title line count:", textLineCount)
    textColor = (0, 0, 0)
    title_padding = padding + titleSize[1] * titleLineCount + line_height * titleLineCount
    for i in range(0, textLineCount):
        drawText = split_text_array[i]
        x = padding
        y = title_padding + i * textSize[1] + i * line_height
        # print("draw text:", drawText, ", x:", x, ", y:", y)
        draw.text((x, y), drawText, font=textFont, fill=textColor)

    del draw

    if output_dir is None:
        output_dir = os.getcwd()

    output_dir = output_dir[0:-1] if output_dir.endswith("/") else output_dir
    image_file_path = output_dir + "/describe.png"
    new_img.save(image_file_path)
    del new_img

    print("output image file:", image_file_path)
    return image_file_path


def make_image_for_file(text_file_path, output_dir,
                        width=512,
                        padding=10,
                        line_height=8,
                        title_font_size=30,
                        text_font_size=20,
                        font_name=None):
    print("make image from file:", text_file_path)

    with open(text_file_path, encoding='utf-8') as file:
        data = file.read()

    print("file content:\n", data)

    return make_image_for_text(data,
                               output_dir=output_dir,
                               width=width,
                               padding=padding,
                               line_height=line_height,
                               title_font_size=title_font_size,
                               text_font_size=text_font_size)


def merge_qrcode_and_describe_image(qrcode_images, qrcode_describes, describe_image,
                                    output_dir=None,
                                    width=512,
                                    qrcode_text_height=30,
                                    text_font_size=20,
                                    text_font_name=None,
                                    author_text_font_size=18,
                                    author="机器人By@黄药师",
                                    bottom_author_height=50,
                                    padding_top=8,
                                    padding_left=8,
                                    padding_right=8,
                                    padding_bottom=8,
                                    describe_padding_left=0,
                                    ):
    print("merge qrcode and describe image start...")

    if qrcode_images is None or qrcode_describes is None or describe_image is None:
        print("merge qrcode and describe image filed.")
        return None

    if len(qrcode_images) != len(qrcode_describes):
        print("merge qrcode and describe image filed.")
        return None

    text_font_path = get_font_file(font_name=text_font_name)
    if text_font_path is None:
        print("make_image filed, can not find font")
        return None

    print("text font path:", text_font_path)

    qrcode_count = len(qrcode_images)
    qrcode_height = int((width - padding_left - padding_right) / qrcode_count)

    desImg = Image.open(describe_image)
    describe_image_width = desImg.size[0]
    describe_image_height = desImg.size[1]
    describe_resize_width = width - padding_left - padding_right
    describe_resize_height = int(describe_resize_width / describe_image_width * describe_image_height)

    print("describe image size",
          " width:", describe_image_width,
          ", height:", describe_image_height,
          ", resize width:", describe_resize_width,
          ", resize height:", describe_resize_height)

    height = qrcode_height + qrcode_text_height + describe_resize_height + bottom_author_height
    print("target image size, width:", width, ", height:", height)
    output_img = Image.new('RGBA', (width, height), (255, 255, 255, 255))
    output_draw = ImageDraw.Draw(output_img)

    # 把描述的图片画上去
    describeX = 0 + padding_left + describe_padding_left
    describeY = qrcode_height + qrcode_text_height
    desResizeImg = desImg.resize((describe_resize_width, describe_resize_height), Image.ANTIALIAS)
    output_img.paste(desResizeImg, (describeX, describeY))
    del desImg
    del desResizeImg

    textFont = ImageFont.truetype(text_font_path, size=text_font_size)
    textColor = (0, 0, 0)

    # 把底部的字加上水印
    bottom_author_text_font = ImageFont.truetype(text_font_path, size=author_text_font_size)
    bottom_author_text_size = textFont.getsize(author)
    bottom_text_x = width - bottom_author_text_size[0]
    bottom_text_y = int(height - bottom_author_text_size[1] - (bottom_author_height - bottom_author_text_size[1]) / 2)
    output_draw.text((bottom_text_x, bottom_text_y), author, font=bottom_author_text_font, fill=textColor)

    # 把QrCode二维码画上去
    for i in range(0, qrcode_count):
        box_width = int((width - padding_left - padding_right) / qrcode_count)
        box_height = qrcode_height - padding_bottom - padding_top
        qrcode_size = int(min(box_width, box_height) * 1)
        print("index:", i, ", qrcode_size:", qrcode_size)

        qrImg = Image.open(qrcode_images[i])
        qrResizeImg = qrImg.resize((qrcode_size, qrcode_size), Image.ANTIALIAS)
        x = int(box_width * i + (box_width - qrcode_size) / 2 + padding_left)
        y = int((box_height - qrcode_size) / 2 + padding_top)
        # print("x:", x, ", y:", y)

        output_img.paste(qrResizeImg, (x, y))
        del qrImg
        del qrResizeImg

        # 把二维码下面的字画上去
        qrcode_text = qrcode_describes[i]
        qrcode_text_size = textFont.getsize(qrcode_text)
        textY = y + qrcode_size + 0
        textX = int(box_width * i + (box_width - qrcode_text_size[0]) / 2 + padding_left)
        output_draw.text((textX, textY), qrcode_text, font=textFont, fill=textColor)

    target_output_path = output_dir + "/target.png"
    print("output image:", target_output_path)
    output_img.save(target_output_path)
    del output_img
    del output_draw
    print("merge qrcode and describe image finish.")
    return target_output_path


def deploy_android(app_name, release_apk_path, test_apk_path,
                   AK=None, SK=None, zone="cn-east-3", bucket="ht-ht-app-test", prefix=None,
                   version_name=None, version_code=None,
                   work_dir=None, describe_file="deploy/update_describe",
                   force=False, qrcode_bg=None, qiye_wechat_webhook=None):
    print("deploy android start...")
    describe_image_width = 700  # 描述的图片的宽度
    merge_image_width = 512  # 合并后的图片的宽度

    bucket_client, url_visit_prefix = make_bucket_client(AK, SK, bucket, zone=zone)
    url_visit_prefix = url_visit_prefix[0:-1] if url_visit_prefix.endswith("/") else url_visit_prefix

    version = version_name
    buildNo = version_code
    print("version:", version, ", buildNo:", buildNo)
    if buildNo is None or version is None:
        print("deploy android failed. can not find version and buildNo")
        return None

    if release_apk_path is None and test_apk_path is None:
        print("deploy android failed. can not find release_apk_path and debug_apk_path")
        return None

    deploy_path_prefix = prefix[0:-1] if prefix.endswith("/") else prefix
    qrcode_images = []
    qrcode_describes = []

    if os.path.exists(qrcode_bg) is False:
        qrcode_bg = None

    if release_apk_path is not None and os.path.exists(release_apk_path):
        # 上传release apk包
        release_deploy_path = "{0}/{1}/{2}.apk".format(deploy_path_prefix, version, buildNo)
        print("release apk:", release_apk_path)
        print("release apk deploy path:", release_deploy_path)
        upload_result_array = upload_file(bucket_client, release_apk_path, release_deploy_path, force)
        if upload_result_array is None:
            print("deploy android failed. upload_file release apk failed")
            return None
        release_apk_full_url = "{0}/{1}".format(url_visit_prefix, upload_result_array[0])
        print("release apk visit url:", release_apk_full_url)

        # 生成release apk下载链接的二维码
        qrcode_save_name = "qrcode_release.png"
        release_qrcode_output_path = make_qrcode(release_apk_full_url,
                                                 work_dir,
                                                 save_name=qrcode_save_name,
                                                 picture=None)
        print("release apk qrcode output:", release_qrcode_output_path)
        qrcode_images.append(release_qrcode_output_path)
        qrcode_describes.append(app_name + "正式版本")

    if test_apk_path is not None and os.path.exists(test_apk_path):
        # 上传test apk包
        test_deploy_path = "{0}/{1}/{2}-test.apk".format(deploy_path_prefix, version, buildNo)
        print("test apk:", test_apk_path)
        print("test apk deploy path:", test_deploy_path)
        upload_result_array = upload_file(bucket_client, test_apk_path, test_deploy_path, force)
        if upload_result_array is None:
            print("deploy android failed. upload_file test apk failed")
            return None
        test_apk_full_url = "{0}/{1}".format(url_visit_prefix, upload_result_array[0])
        print("test apk visit url:", test_apk_full_url)

        # 生成test apk下载链接的二维码
        qrcode_save_name = "qrcode_test.png"
        test_qrcode_output_path = make_qrcode(test_apk_full_url,
                                              work_dir,
                                              save_name=qrcode_save_name,
                                              picture=qrcode_bg)
        print("test apk qrcode output:", test_qrcode_output_path)
        qrcode_images.append(test_qrcode_output_path)
        qrcode_describes.append(app_name + "测试版本")

    # 生成更新描述的图片
    describe_output_path = make_image_for_file(describe_file, work_dir, width=describe_image_width)
    print("describe image output:", describe_output_path)

    # 生成最终的图,把更新描述的图片和二维码合并成最终的图
    merge_image_output_path = merge_qrcode_and_describe_image(qrcode_images,
                                                              qrcode_describes,
                                                              describe_output_path,
                                                              width=merge_image_width,
                                                              output_dir=work_dir)
    print("merge image output:", merge_image_output_path)

    # 上传最终的图到OBS
    merge_deploy_path = "{0}/{1}/{2}-{3}".format(deploy_path_prefix,
                                                 version, buildNo,
                                                 merge_image_output_path.split("/")[-1])
    print("target deploy path:", merge_deploy_path)
    upload_result_array = upload_file(bucket_client, merge_image_output_path, merge_deploy_path, force)
    if upload_result_array is None:
        print("deploy android failed. upload_file target qrcode image failed.")
        return None
    merge_image_full_url = "{0}/{1}".format(url_visit_prefix, upload_result_array[0])
    print("target image visit url:", merge_image_full_url)

    if qiye_wechat_webhook is None:
        print("skip send msg to qiye wechat")
    else:
        if send_image_to_qiye_wechat(qiye_wechat_webhook, merge_image_output_path):
            print("send msg to qiye wechat success.")
        else:
            print("send msg to qiye wechat failed.")

    print("deploy android success.")
    return merge_image_full_url


# https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=43d9def0-a088-441c-a64a-d3653a25337f
# Content-Type:application/json

# 当前自定义机器人支持文本（text）、markdown（markdown）、图片（image）、图文（news）四种消息类型。
# {
#   "msgtype": "text",
#   "text": {
#               "content": "正在测试机器人",
#               "mentioned_list":["wangqing","@all"],
#               "mentioned_mobile_list":["13800001111","@all"]
#           }
# }
# msgtype: 消息类型，此时固定为text
# content: 文本内容，最长不超过2048个字节，必须是utf8编码
# mentioned_list: userid的列表，提醒群中的指定成员(@某个成员)，@all表示提醒所有人，如果开发者获取不到userid，可以使用mentioned_mobile_list
# mentioned_mobile_list: 手机号列表，提醒手机号对应的群成员(@某个成员)，@all表示提醒所有人
#
# 图片image
# {
#     "msgtype": "image",
#     "image": {
#         "base64": "DATA",
#         "md5": "MD5"
#     }
# }
#
# 图文类型
# {
#     "msgtype": "news",
#     "news": {
#        "articles" : [
#            {
#                "title" : "中秋节礼品领取",
#                "description" : "今年中秋节公司有豪礼相送",
#                "url" : "www.qq.com",
#                "picurl" : "http://res.mail.qq.com/node/ww/wwopenmng/images/independent/doc/test_pic_msg1.png"
#            }
#         ]
#     }
# }
# msgtype	是	消息类型，此时固定为news
# articles	是	图文消息，一个图文消息支持1到8条图文
# title	是	标题，不超过128个字节，超过会自动截断
# description	否	描述，不超过512个字节，超过会自动截断
# url	是	点击后跳转的链接。
# picurl	否	图文消息的图片链接，支持JPG、PNG格式，较好的效果为大图 1068*455，小图150*150。
#
# "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=43d9def0-a088-441c-a64a-d3653a25337f"
def send_text_to_qiye_wechat(webhook, text):
    web_hook_url = webhook
    print("send msg to qiyewechat...")
    print("web_hook_url:", web_hook_url)
    if web_hook_url is None:
        return False

    print("text:", text)
    body = {'msgtype': 'text', 'text': {'content': text}}
    json_str = json.dumps(body)
    req = urllib.request.Request(web_hook_url, data=json_str.encode("utf-8"), method="POST")
    res_json = None
    try:
        with urllib.request.urlopen(req) as response:
            response_json_str = response.read()
            print("response_json_str:", response_json_str)
            res_json = json.loads(response_json_str)
    except BaseException:
        return False

    return res_json is not None and res_json["errcode"] == 0


def send_image_to_qiye_wechat(webhook, image_path):
    web_hook_url = webhook
    print("send msg to qiyewechat...")
    print("web_hook_url:", web_hook_url)
    if web_hook_url is None:
        return False

    print("image path:", image_path)
    try:
        with open(image_path, 'rb') as file:
            file_bin_data = file.read()
            base64_data = base64.b64encode(file_bin_data)
            file_md5 = hashlib.md5(file_bin_data).hexdigest()
        body = {'msgtype': 'image', 'image': {'base64': base64_data.decode("utf-8"), 'md5': file_md5}}
        print("file_md5:", file_md5)
        json_str = json.dumps(body)
    except BaseException:
        return False

    req = urllib.request.Request(web_hook_url, data=json_str.encode("utf-8"), method="POST")
    res_json = None
    try:
        with urllib.request.urlopen(req) as response:
            response_json_str = response.read()
            print("response_json_str:", response_json_str)
            res_json = json.loads(response_json_str)
    except BaseException:
        return False

    return res_json is not None and res_json["errcode"] == 0


def print_help():
    print(
        """
      Usage:python deploy.py [option]
      -h or -? or --help    显示帮助信息
      -n or --name          项目名称。默认:航天智行App
      -t or --type          项目类型:android、ios、web。默认:android
      -p or --projectDir    项目目录。默认:当前目录
      -f or --force         要部署的路径文件存在，强制覆盖
            --release       要部署正式版本的本地路径
            --test          要部署测试版本的本地路径
      -V or --version       要部署的版本信息
      -b or --buildNo       要部署打包号
      -d or --describe      更新描述存放的本地路径。默认:update_describe
            --obsAK         华为云OBS的AK
            --obsSK         华为云OBS的SK
            --obsBucket     华为云OBS的bucket
            --obszone       华为云OBS的区域。默认:cn-east-3
            --deploy        华为云OBS的部署的路径前缀。默认:deploy/
      -w or --workDir      工作目录，就是产生的中间文件存放的地方。默认:.deploy
      -s or --qiyeWechat   企业微信的Webhook地址
    
      """
    )


if __name__ == '__main__':

    script_path = os.path.realpath(__file__)
    script_dir = os.path.dirname(script_path)
    project_dir = os.getcwd()
    project_name = "航天智行App"
    project_type = "android"

    release_apk_path = None
    test_apk_path = None

    force = False
    version = None
    build_no = None
    version_describe_file = None

    # user=app_obs_deploy
    # obs_AK = 'OECTQ8MSHL6TPYBJ7QKQ'
    # obs_SK = 'RTMZaBj4av5g22W5r2s4JSmvJVxRgL6SlGKT4imI'
    # obs_bucket = "ht-ht-app-test"
    obs_deploy_path = None
    obs_zone = "cn-east-3"

    work_dir = None
    qiye_wechat_webhook = None

    try:
        shortopts = "h?n:t:p:fV:b:d:w:s:"
        longopts = ["help",
                    "name=",
                    "type=",
                    "projectDir=",
                    "force",
                    "release=",
                    "test=",
                    "version=",
                    "buildNo=",
                    "describe=",
                    "obsAK=",
                    "obsSK=",
                    "obsBucket=",
                    "deploy=",
                    "workDir=",
                    "qiyeWechat=",
                    ]

        opts, args = getopt.getopt(sys.argv[1:], shortopts, longopts)
        for name, value in opts:
            if name in ("-h", "-?", "--help"):
                print_help()
            if name in ('-n', '--name'):
                project_name = value.lower()
            if name in ('-t', '--type'):
                project_type = value
                if project_type not in ("android", "ios", "web"):
                    raise ValueError('project_type')
            if name in ('-p', '--projectDir'):
                project_dir = value
                if os.path.exists(project_dir) is False:
                    raise ValueError('project_dir not exists')
            if name in ('-f', '--force'):
                force = True
            if name == '--release':
                release_apk_path = value
            if name == '--test':
                test_apk_path = value
            if name in ('-V', '--version'):
                version = value
            if name in ('-b', '--buildNo'):
                build_no = value
            if name in ('-d', '--describe'):
                version_describe = value
            if name == '--obsAK':
                obs_AK = value
            if name == '--obsSK':
                obs_SK = value
            if name == '--obsBucket':
                obs_bucket = value
            if name in ('-w', '--workDir'):
                work_dir = value
            if name in ('-s', '--qiyeWechat'):
                qiye_wechat_webhook = value

    except BaseException as e:
        print_help()
        sys.exit(1)

    print("project dir:", project_dir)
    if os.path.exists(project_dir) is False:
        print("project_dir is not exists:", project_dir)
        sys.exit(2)

    project_dir = os.path.abspath(project_dir)

    if obs_AK is None or obs_SK is None or obs_zone is None or obs_bucket is None:
        print("--obsAK、--obsSK、obsBucket should be set")
        sys.exit(3)
    if obs_deploy_path is None:
        obs_deploy_path = "deploy/"

    if version is None or build_no is None:
        print("--version and --buildNo should be set")
        sys.exit(4)

    if version_describe_file is None:
        version_describe_file = project_dir + "/update_describe"

    if os.path.exists(version_describe_file) is False:
        print("describe file is not exists:", version_describe_file)
        sys.exit(5)

    print("describe file:", version_describe_file)

    if work_dir is None:
        work_dir = script_dir + "/.htdeploy"

    print("work dir:", work_dir)

    if project_type == "android":
        release_apk_not_exists = release_apk_path is None or os.path.exists(release_apk_path) is False
        test_apk_not_exists = test_apk_path is None or os.path.exists(test_apk_path) is False
        if release_apk_not_exists is True and test_apk_not_exists is True:
            print("release and test apk file all not exists")
            sys.exit(6)

        print("release apk file:", release_apk_path)
        print("test apk file:", test_apk_path)

        merge_image_path = deploy_android(
            app_name=project_name, release_apk_path=release_apk_path, test_apk_path=test_apk_path,
            AK=obs_AK, SK=obs_SK, zone=obs_zone, bucket=obs_bucket, prefix=obs_deploy_path,
            version_name=version, version_code=build_no,
            describe_file=version_describe_file,
            force=force,
            qrcode_bg=script_dir + "/bg.jpg",
            work_dir=work_dir,
            qiye_wechat_webhook=qiye_wechat_webhook,
        )
        if merge_image_path is None:
            send_text_to_qiye_wechat(qiye_wechat_webhook, "打包失败")
