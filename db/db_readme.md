前綴：http://192.168.112.134:8000/api/
- user/
  - POST
    - 功能：把台北通的姓名、身分證字號傳進來，在後端建立使用者
    - 變數：{"user_name"："姓名", "user_peopleID", "身分證字號"}
    - 回傳物件的\["user_id"]就是該使用者的唯一id

- user/<uuid:uuid>/
  - GET
    - 功能：api地址輸入user的id，得到user的姓名及獲得讚、倒讚數
- post/
  - GET
    - 功能：拿到所有POST的相關資訊
    - post_info = {
                'post_id': post_data['post_id'],
                'user_name': post_data['user_name'],
                'longitude': post_data['longitude'],
                'latitude': post_data['latitude'],
                'address': post_data['address'],
                'food_description': post_data['food_description'],
                'post_time': post_data['post_time'],
                'finish_time': post_data['finish_time'],
                'food_num': post_data['food_num'],
                'status': post_data['status'],
                'food_kinds': food_kinds,  # 包含所有食物種類的列表
                'image_codes': image_codes,  # 包含所有圖片碼的列表
                'num_likes': post_data['num_likes'],  # 贊總數
                'num_dislikes': post_data['num_dislikes'],  # 倒贊總數
                'num_interests': post_data['num_interests'],  # 對該 post 感興趣的人數
                'taked_quantity': post_data['taked_quantity'],  # 該 post 下的數量總數
            }
  - POST
    - 功能：創建新的event
    - 變數：{"user_id"："", "longitude"："", "latitude"："", "food_description", "finish_time"：要是timestamp, "food_num"："", food_kinds：\["",""], image_codes：\["",""]}
    - 回傳該event物件
- like/<uuid:uuid>/<uuid:receiverid>/
  - GET
    - 功能：知道a使用者對b使用者是按讚還是倒讚
    - 回傳-1代表沒按過，true代表按讚，false代表倒讚
- like/
  - POST
    - 功能：讓a使用者按讚b使用者
    - 變數：{"liker_id"："", "receiver_id"："", "like_or_dislike"："1或0"}
    - 回傳該a、b的id
- interest/<uuid:uuid>/<uuid:postid>/
  - GET
    - 功能：知道a使用者對b event有沒有興趣
    - 回傳 true代表有興趣，false代表沒興趣
- interest/
    - POST
      - 功能：讓a使用者對b活動有興趣
      - 變數：{"user_id"："", "post_id"："", "longitude"："", "latitude"： ""}
      - 回傳該a、b的id
- take/<uuid:uuid>/<uuid:postid>/
  - GET
    - 功能：知道a使用者對b event有沒有拿過東西
    - 回傳 true代表有拿過，false代表沒拿過
- take/
    - POST
      - 功能：讓a使用者對b活動申報拿了幾個東西
      - 變數：{"user_id"："", "post_id"："", "quantity"：""}
      - 回傳該a、b的id
- empty/
    - POST
      - 功能：有人回報已經沒東西時，直接把post的status關了
      - 變數：{"post_id"：""}
      - 回傳status