import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:rooya_app/ApiUtils/AuthUtils.dart';

import '../helpers/helper.dart';
import '../models/sound_model.dart';
import 'user_repository.dart';

ValueNotifier<SoundModelList> soundsData = new ValueNotifier(SoundModelList());
ValueNotifier<SoundModelList> catSoundsData =
    new ValueNotifier(SoundModelList());
ValueNotifier<bool> mic = new ValueNotifier(true);
ValueNotifier<SoundModelList> favSoundsData =
    new ValueNotifier(SoundModelList());
ValueNotifier<SoundData> currentSound =
    new ValueNotifier(SoundData(id: 0, title: ""));

Future<SoundModelList> getData(page, searchKeyword) async {
  try {
    var response = await http.post(
        Uri.parse(
            'https://rooyapis.rooyatech.com/Alphaapis/getDeezerSounds?code=ROOYA-5574499'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": '${await getToken()}'
        },
        body: jsonEncode({"search": '$searchKeyword', "index": '0', "limit": '10'}));
    if (response.statusCode == 200) {
      if (response.statusCode == 200) {
        if (page > 1) {
          soundsData.value.soundData!.addAll(
              SoundModelList.fromJson(json.decode(response.body))
                  .soundData!
                  .toList());
        } else {
          soundsData.value =
              SoundModelList.fromJson(json.decode(response.body));
        }
      }
    }
  } catch (e) {
    print(e.toString());
    soundsData.value = SoundModelList.fromJson({});
  }
  soundsData.notifyListeners();
  return soundsData.value;
}

Future<SoundModelList> getCatData(catId, page, searchKeyword) async {
  if (searchKeyword != '' && searchKeyword != null) {
    catSoundsData.value = SoundModelList.fromJson({});
    catSoundsData.notifyListeners();
  }
  Uri uri = Helper.getUri('get-cat-sounds');
  uri = uri.replace(
      queryParameters: {'cat_id': catId.toString(), 'search': searchKeyword});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          catSoundsData.value.soundData!.addAll(
              SoundModelList.fromJson(json.decode(response.body))
                  .soundData!
                  .toList());
        } else {
          catSoundsData.value =
              SoundModelList.fromJson(json.decode(response.body));
        }
      }
    }
  } catch (e) {
    print(e.toString());
    soundsData.value = SoundModelList.fromJson({});
  }
  catSoundsData.notifyListeners();
  return catSoundsData.value;
}

Future<SoundModelList> getFavData(page, searchKeyword2) async {
  print('searchKeyword2 = $searchKeyword2');
  try {
    var response = await http.post(
        Uri.parse(
            'https://rooyapis.rooyatech.com/Alphaapis/getDeezerSounds?code=ROOYA-5574499'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": '${await getToken()}'
        },
        body: jsonEncode(
            {"search": '$searchKeyword2', "index": '0', "limit": '10'}));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          favSoundsData.value.soundData!.addAll(
              SoundModelList.fromJson(json.decode(response.body))
                  .soundData!
                  .toList());
        } else {
          favSoundsData.value =
              SoundModelList.fromJson(json.decode(response.body));
        }
      }
    }
  } catch (e) {
    print(e.toString());
    favSoundsData.value = SoundModelList.fromJson({});
  }
  favSoundsData.notifyListeners();
  return favSoundsData.value;
}

Future<String> setFavSound(soundId, set) async {
  Dio dio = new Dio();
  dio.options.baseUrl = Helper.getUri('').toString();

  try {
    var response = await dio.post("set-fav-sound",
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ' + currentUser.value.token,
          },
        ),
        queryParameters: {
          "sound_id": soundId,
          "set": set,
        });
    if (response.statusCode == 200) {
      if (response.data['status'] == 'success') {}
      return response.data['msg'];
    } else {
      return "There's some server side issue";
    }
  } catch (e) {
    print(e.toString());
    return "There's some server side issue";
  }
}

Future<SoundData> getSound(soundId) async {
  SoundData sound = SoundData.fromJson({});
  try {
    String apiUrl = Helper.getUri("get-sound").toString();
    var response = await Dio().post(
      apiUrl,
      options: Options(
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ' + currentUser.value.token,
        },
      ),
      queryParameters: {
        "sound_id": soundId.toString(),
      },
    );

    if (response.statusCode == 200) {
      print(response.data);
      if (response.data['status'] == 'success') {
        var map = Map<String, dynamic>.from(response.data['data']);
        sound = SoundData.fromJson(map);
      }
    }
  } catch (e) {
    print(e);
    sound = SoundData.fromJson({});
  }
  return sound;
}

Future<SoundData> selectSound(SoundData sound) async {
  currentSound.value = sound;
  currentSound.notifyListeners();
  return currentSound.value;
}
