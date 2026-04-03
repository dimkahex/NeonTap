# Firebase — что сделать вручную

В коде сначала выставь **`kFirebaseOnlineFeaturesEnabled = true`** в `lib/src/config/online_config.dart`, затем настрой консоль ниже.

ИИ/агент **не может** зайти в [Firebase Console](https://console.firebase.google.com) за тебя: нужен твой Google-аккаунт и доступ к проекту.

Ниже — порядок действий один раз на проект. После этого рейтинг и друзья заработают на устройстве с **настоящим** `google-services.json`.

---

## 1. Создать (или выбрать) проект Firebase

1. Открой https://console.firebase.google.com  
2. **Add project** / выбери существующий проект.

---

## 2. Authentication — анонимный вход

1. В меню: **Build → Authentication → Sign-in method**  
2. Включи **Anonymous** и сохрани.

Без этого приложение не получит `auth.uid`, а правила RTDB для записи очков не сработают.

---

## 3. Realtime Database

1. **Build → Realtime Database**  
2. **Create Database**  
3. Регион — ближе к игрокам (например `europe-west1`).  
4. На первом шаге можно выбрать **locked mode** — сразу после создания замени правила на файл из этого репозитория (шаг 5).

---

## 4. Android-приложение в Firebase

1. Настройки проекта (шестерёнка) → **Project settings**  
2. Внизу **Your apps** → иконка **Android**  
3. **Android package name** должен **совпадать** с тем, что в твоём `android/app/build.gradle` (`applicationId`).  
   Для шаблона из CI обычно: **`com.neonpulse.neon_pulse_online`**  
4. Зарегистрируй приложение → **Download `google-services.json`**  
5. Положи файл в проект: **`android/app/google-services.json`** (не коммить в публичный репо, если боишься утечек — для open source часто коммитят, ключи не секрет для клиента).

Если папки `android/` ещё нет локально:

```bash
flutter create --platforms=android --project-name neon_pulse_online .
```

(организацию `com.neonpulse` подставь как у тебя в проекте.)

---

## 5. Правила базы (обязательно)

1. **Realtime Database → Rules**  
2. Скопируй **всё** содержимое файла **`database.rules.json`** из этой папки (`firebase/database.rules.json`)  
3. Нажми **Publish**

Без **`.indexOn": "score"`** на `leaderboard/global` запрос глобального топа с сортировкой по `score` **упадёт** с ошибкой индекса.

---

## 6. Проверка на телефоне

1. `flutter pub get`  
2. Подключи устройство или эмулятор  
3. `flutter run`  
4. Сыграй забег → в консоли RTDB должна появиться ветка `leaderboard/global/<uid>`  
5. Открой **Рейтинг** в приложении — список должен подтянуться.

---

## Что уже сделано в коде (не в консоли)

- Логика записи лучшего счёта, глобальный топ, друзья по коду, правила в **`database.rules.json`** в репозитории.

---

## Если что-то не работает

| Симптом | Что проверить |
|--------|----------------|
| Пустой топ, ошибки в логе про **index** | Правила из `database.rules.json` опубликованы полностью |
| **Permission denied** | Включён Anonymous Auth; пользователь залогинен анонимно |
| Приложение не коннектится к Firebase | Реальный `google-services.json` в `android/app/`, верный `applicationId` |
| CI-сборка | В workflow по-прежнему может копироваться **placeholder** `google-services.json` — для **реального** онлайна на устройстве нужен свой файл локально или секрет в CI |

---

## Кратко: что делаешь **ты**, что уже есть **в репо**

| Ты в консоли | Уже в репозитории |
|--------------|-------------------|
| Проект, Auth Anonymous, RTDB, правила, скачать `google-services.json` | Код сервисов, экран рейтинга, `database.rules.json` |
