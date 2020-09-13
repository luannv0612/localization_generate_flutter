# localization_generator

A command tool to generate localization from JSON file.

![Dart CI](https://github.com/luannv0612/localization_generator)

## Usage

create `en.json` and `vi.json` at l10n folder

en.json
```json
{
    "hi": "Hi",
    "hello": "Hello {name}",
    "price": "100 {currency, select, TWD{NT} other{\\$}}",
    "gender": "gender: {gender, gender, female{female} male{male} other{other}}",
    "reply": "{count, plural, =0{no reply} =1{1 reply} other{# replies}}"
}
```

vi.json
```json
{
    "hi": "Xin chao",
    "hello": "Xin chao {name}",
    "price": "100 {currency, select, TWD{NT} other{\\$}}",
    "gender": "gender: {gender, gender, female{female} male{male} other{other}}",
    "reply": "{count, plural, =0{no reply} =1{1 reply} other{# replies}}"
}
```

and run this command
```
flutter pub run localization_generator --output=./l10n --input=./l10n
```

```
import 'l10n/localization.dart';

MaterialApp(
  onGenerateTitle: (context) {
    return Localized.of(context).hello(name: "my name");
  },
  theme: ThemeData(
    primarySwatch: Colors.blue,
  ),
  localizationsDelegates: [
    Localized.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate
  ],
  supportedLocales: Localized.delegate.supportedLocales,
  home: Builder(builder: (context) {
    return Column(
      children: [
        Text(Localized.of(context).hi),
        Text(Localized.of(context).price(currency: "TWD")),
        Text(Localized.of(context).gender(gender: "female")),
        Text(Localized.of(context).reply(count: 0)),
      ],
    );
  }),
);
```
