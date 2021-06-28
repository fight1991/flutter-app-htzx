import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../i18n/index.dart';
import 'base_response.dart';

class ApiStatus<T extends ApiResponse> {
  BuildContext context;
  T apiResponse;
  dynamic error;
  String status;

  ApiStatus(this.context, {this.apiResponse, this.error, this.status});

  static String apiStatusLoading = "status_loading";
  static String apiStatusSuccess = "status_success";
  static String apiStatusError = "status_error";
  static String apiStatusInit = "status_init";

  void reset({bool retry = false}) {
    this.status = apiStatusLoading;
    this.apiResponse = null;
    this.error = null;
  }

  void apiSuccess(T apiResponse) {
    this.status = apiStatusSuccess;
    this.apiResponse = apiResponse;
  }

  void apiError(dynamic error) {
    print("apiError, $error");
    this.status = apiStatusError;
    this.error = error;
  }

  bool isInitializing() {
    return status == null || status == apiStatusInit;
  }

  bool isLoading() {
    return status == apiStatusLoading;
  }

  bool isApiSuccess() {
    return status == apiStatusSuccess;
  }

  bool isApiError() {
    return status == apiStatusError;
  }

  bool isServiceSuccess() {
    return isApiSuccess() &&
        apiResponse != null &&
        apiResponse.isServiceSuccess();
  }

  int getServiceCode() {
    if (!isApiSuccess()) {
      return null;
    }
    if (apiResponse is AppApiResponse) {
      AppApiResponse appApiResponse = apiResponse as AppApiResponse;
      return appApiResponse.code;
    }
    if (apiResponse is AppApiResponsePage) {
      AppApiResponsePage appApiResponsePage = apiResponse as AppApiResponsePage;
      return appApiResponsePage.code;
    }
    return null;
  }

  String getErrorMsg() {
    if (isApiError()) {
      if (error is DioError) {
        DioError dioError = error as DioError;
        if (dioError.type == DioErrorType.CANCEL) {
          return L.of(context).apiHttpCancel;
        } else if (dioError.type == DioErrorType.RESPONSE) {
          var statusCode = dioError.response?.statusCode;
          statusCode ??= -1;
          if (400 <= statusCode && statusCode < 500) {
            return L.of(context).apiHttpError4xx;
          } else if (500 <= statusCode) {
            return L.of(context).apiHttpError5xx;
          }
        }
      }
      if (error is ArgumentError) {
        return L.of(context).apiArgumentError;
      }
      if (error is CastError || error is TypeError) {
        return L.of(context).apiJsonError;
      }
      return L.of(context).apiHttpError;
    }
    if (!isServiceSuccess()) {
      if (apiResponse is AppApiResponse) {
        AppApiResponse response = apiResponse as AppApiResponse;
        return response.msg;
      }
      return L.of(context).apiServiceError;
    }
    return L.of(context).apiServiceSuccess;
  }
}
