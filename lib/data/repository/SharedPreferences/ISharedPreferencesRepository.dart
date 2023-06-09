abstract class ISharedPreferencesRepository {

  Future<bool> setLocalizedStrings(Map<String, String> localizedStrings);
  Future<Map<String, dynamic>> getLocalizedStrings();
  Future setTheme(int keyValue);
  Future getTheme();
  Future setBackUp(String backUpKey,int backUpValue);
  Future getBackUp(String backUpKey);
}