import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {

  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'login': 'Login',
      'register': 'Register',
      'cooking_master': 'Cooking Master',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'login_btn': 'Login',
      'register_btn': 'Register',
      'dont_have_account': "Don't have an account? Register",
      'already_have_account': 'Already have an account? Login',
      'preferences': 'Preferences',
      'language': 'Language',
      'english': 'English',
      'russian': 'Russian',
      'german': 'German',
      'please_enter_email_and_password': 'Please enter email and password',
      'please_fill_all': 'Please fill in all fields',
      'error': 'Error',
      'ok': 'OK',
      'welcome': 'Welcome, {name}!',
      'email_label': 'Email: {email}',
      'recipes_soon': 'Your recipes will appear here soon!',
      'logout': 'Logout',
      'receipts': 'Recipes',
      'ingredients': 'Ingredients',
      'recommendations': 'Recommendations',
      'add_ingredient': 'Add Ingredient',
      'ingredient_name': 'Name',
      'calories': 'Calories',
      'upload_photo': 'Upload Photo',
      'save': 'Save',
      'invalid_number': 'Please enter a valid number',
      'edit_ingredient': 'Edit Ingredient',
      'update': 'Update',
    },
    'ru': {
      'login': 'Вход',
      'register': 'Регистрация',
      'cooking_master': 'Кулинарный мастер',
      'email': 'Эл. почта',
      'password': 'Пароль',
      'name': 'Имя',
      'login_btn': 'Войти',
      'register_btn': 'Зарегистрироваться',
      'dont_have_account': 'Нет аккаунта? Зарегистрируйтесь',
      'already_have_account': 'Уже есть аккаунт? Войти',
      'preferences': 'Настройки',
      'language': 'Язык',
      'english': 'Английский',
      'russian': 'Русский',
      'german': 'Немецкий',
      'please_enter_email_and_password': 'Пожалуйста, введите эл. почту и пароль',
      'please_fill_all': 'Пожалуйста, заполните все поля',
      'error': 'Ошибка',
      'ok': 'ОК',
      'welcome': 'Добро пожаловать, {name}!',
      'email_label': 'Эл. почта: {email}',
      'recipes_soon': 'Ваши рецепты появятся здесь в ближайшее время!',
      'logout': 'Выйти',
      'receipts': 'Рецепты',
      'ingredients': 'Ингредиенты',
      'recommendations': 'Рекомендации',
      'add_ingredient': 'Добавить ингредиент',
      'ingredient_name': 'Название',
      'calories': 'Калории',
      'upload_photo': 'Загрузить фото',
      'save': 'Сохранить',
      'invalid_number': 'Пожалуйста, введите правильное число',
      'edit_ingredient': 'Редактировать ингредиент',
      'update': 'Обновить',
    },
    'de': {
      'login': 'Anmelden',
      'register': 'Registrieren',
      'cooking_master': 'Cooking Master',
      'email': 'E-Mail',
      'password': 'Passwort',
      'name': 'Name',
      'login_btn': 'Anmelden',
      'register_btn': 'Registrieren',
      'dont_have_account': 'Kein Konto? Registrieren',
      'already_have_account': 'Bereits ein Konto? Anmelden',
      'preferences': 'Einstellungen',
      'language': 'Sprache',
      'english': 'Englisch',
      'russian': 'Russisch',
      'german': 'Deutsch',
      'please_enter_email_and_password': 'Bitte E-Mail und Passwort eingeben',
      'please_fill_all': 'Bitte füllen Sie alle Felder aus',
      'error': 'Fehler',
      'ok': 'OK',
      'welcome': 'Willkommen, {name}!',
      'email_label': 'E-Mail: {email}',
      'recipes_soon': 'Ihre Rezepte werden hier bald erscheinen!',
      'logout': 'Abmelden',
      'receipts': 'Rezepte',
      'ingredients': 'Zutaten',
      'recommendations': 'Empfehlungen',
      'add_ingredient': 'Zutat hinzufügen',
      'ingredient_name': 'Name',
      'calories': 'Kalorien',
      'upload_photo': 'Foto hochladen',
      'save': 'Speichern',
      'invalid_number': 'Bitte geben Sie eine gültige Nummer ein',
      'edit_ingredient': 'Zutat bearbeiten',
      'update': 'Aktualisieren',
    },
  };

  String translate(String key, [Map<String, String>? params]) {
    final lang = locale.languageCode;
    final map = _localizedValues[lang] ?? _localizedValues['en']!;
    var text = map[key] ?? key;
    params?.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
