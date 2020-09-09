# i18n_code_gen!

Generate file json to Strings.dart

## Integrated:
add file ***pubspec.yaml***:
```
dependencies:  
  flutter_localizations:  
    sdk: flutter  
  flutter_cupertino_localizations: ^1.0.1
```
```
dev_dependencies:  
  build_runner: ^1.7.3  
  localization_generator:
    git: https://github.com/luannv0612/localization_generator.git
```
create file ***build.yaml*** in folder project:
```
targets:  
  #edit your_project_package_name 
  #the same name in pubspec.yaml  
  test_localization_code_gen:test_localization_code_gen:  
    builders:  
      localization_generator|localizationBuilder:  
        generate_for:  
          - lib/res/strings/*
```
run command packages get:  ```flutter pub get```

## Use
#### add file ***.json*** in folder ```lib/res/strings/``` with file name ***language code*** example: ```en.json```
```
{  
  "isDefault": true,
  "lang": "en",  
  "app_name": "Test App",  
  "content": "Test auto gen language code",
  "two_parameters": "Test format string: $parameter1 and $parameter2"
}
```
"isDefault": true set default language use

#### Run command  ```flutter packages pub run build_runner build```
file Strings.dart is generated in folder ***lib/res/strings***
#### Thêm vào main.dart:
add params use MaterialApp: ***localizationsDelegates, supportedLocales, localeResolutionCallback***
```
class MyApp extends StatelessWidget {  
  // This widget is the root of your application.  
  @override  
  Widget build(BuildContext context) {  
    return MaterialApp(  
      localizationsDelegates: [  
        Strings.delegate,  
        GlobalMaterialLocalizations.delegate,  
        GlobalWidgetsLocalizations.delegate,  
      ],  
      supportedLocales: Strings.delegate.supportedLocales,  
      localeResolutionCallback: Strings.localeResolutionCallback,  
      ...
```
## use code:
```
Text(Strings.of(context).content) //text: 'Test auto gen language code'
```

## use text with params (format):
json ```"two_parameters": "Test format string: $parameter1 and $parameter2"```
```
Text(Strings.of(context).two_parameters('Tom', 'Jerry')) //text: 'Test format string: Tom and Jerry'
```