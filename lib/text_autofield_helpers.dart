import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_places_autocomplete_text_field/model/place_details.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';

class GooglePlaceAutofieldHelpers {
  final String googleAPIKey;
  String? proxyURL;
  final Dio _dio = Dio();

  GooglePlaceAutofieldHelpers({required this.googleAPIKey, this.proxyURL});

  Future<List<Prediction>?> getPredictionList(
      {required String text,
      List<String>? countries,
      Dio? dio,
      String? prefix}) async {
    try {
      final prefix = proxyURL ?? "";
      String url =
          "${prefix}https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$text&key=$googleAPIKey";
      if (countries != null) {
        for (int i = 0; i < countries.length; i++) {
          final country = countries[i];
          if (i == 0) {
            url = "$url&components=country:$country";
          } else {
            url = "$url|country:$country";
          }
        }
      }
      final response = await (dio ?? Dio()).get(url);
      final subscriptionResponse =
          PlacesAutocompleteResponse.fromJson(response.data);
      return subscriptionResponse.predictions;
    } catch (e) {
      if (e is DioException) {
        if (kDebugMode) print(e.response?.data);
      }
      return [];
    }
  }

  Future<Prediction?> getPlaceDetailsFromPlaceId(Prediction prediction) async {
    try {
      final prefix = proxyURL ?? "";
      final url =
          "${prefix}https://maps.googleapis.com/maps/api/place/details/json?placeid=${prediction.placeId}&key=${googleAPIKey}";
      final response = await _dio.get(
        url,
      );
      final placeDetails = PlaceDetails.fromJson(response.data);
      prediction.lat = placeDetails.result!.geometry!.location!.lat.toString();
      prediction.lng = placeDetails.result!.geometry!.location!.lng.toString();
      return prediction;
    } catch (e) {
      rethrow;
    }
  }
}
