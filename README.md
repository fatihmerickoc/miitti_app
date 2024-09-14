# 🎉 Miitti App:
miitti app is a mobile app that helps people make new friends through shared hobbies and interests. connect with like-minded individuals, discover local events, and create your own gatherings - all in one place!

TL;DR Facebook + Tinder combined with a map

## 👩🏽‍🍳 Features
- **social networking**: create a profile, add friends, and chat with other users who share your passions
- **event discovery**: explore a map powered by Mapbox to find nearby events and activities  
- **hobby-based matching**: get matched with potential friends based on your mutual hobbies and location.
- **real-time notifications**: recieve push notifications about new events, friennd requests, and messages

## 📱 Download the App
you can download our app from your favorite store:

[Download on Google Play](https://play.google.com/store/apps/details?id=com.miittisoftwareoy.miitti_app)

[Download on the App Store](https://apps.apple.com/fi/app/miitti-app/id6451346402?l=fi)
  
## 🧑‍🎨 Designs
<div style="display: flex; flex-wrap: wrap;">
  <img src="https://github.com/user-attachments/assets/96577837-f174-40ad-9917-5594aee615a3" alt="Screenshot 1" width="200" style="margin-right: 10px; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/0cdc3c85-6ac3-4654-abae-e11c9835cd9c" alt="Screenshot 2" width="200" style="margin-right: 10px; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/2eee033a-8aef-4660-a04e-06bbf1d2f726" alt="Screenshot 3" width="200" style="margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/8d8edc47-7061-4b96-bda0-965ba6d54627" alt="Screenshot 4" width="200" style="margin-right: 10px; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/c431a531-d36d-41bf-b0a5-60a52b028b98" alt="Screenshot 5" width="200" style="margin-right: 10px; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/2849759c-a2c0-4ce0-ad8e-1abef28d00b3" alt="Screenshot 6.1" width="200" style="margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/29ee313a-12fa-41f1-a15e-b020b2c2f49b" alt="Screenshot 9" width="200" style="margin-right: 10px; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/fc478859-45a0-418b-95a7-aa4e887c4fcc" alt="Screenshot 10" width="200" style="margin-right: 10px; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/da55eae2-1198-4a31-ab71-6d6bd6401484" alt="Screenshot 11" width="200" style="margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/db8586fc-59d9-40b2-a074-13e017461707" alt="Screenshot 12" width="200" style="margin-right: 10px; margin-bottom: 10px;">
  <img src="https://github.com/user-attachments/assets/af46a27b-9283-47b2-93f8-99ec601ff56c" alt="Screenshot 13" width="200" style="margin-right: 10px; margin-bottom: 10px;">
    <img src="https://github.com/user-attachments/assets/afe2e532-643d-4ed1-9980-ca83953ef420" alt="Screenshot 7" width="200" style="margin-right: 10px; margin-bottom: 10px;">
    <img src="https://github.com/user-attachments/assets/05eb51e0-f54e-4abb-80db-410e1d41cadf" alt="Screenshot 8" width="200" style="margin-bottom: 10px;">
    <img src="https://github.com/user-attachments/assets/480de99a-ad05-4fae-bbeb-aa3cc4cc84d5" alt="Screenshot 6" width="200" style="margin-right: 10px; margin-bottom: 10px;">
</div>

## 🗺️ Mapbox Integrationn
this app uses mapbox to provide an interactice map for events, here's how it works:
1. The **Mapbox SDK** is set up with API keys.
   
2. Event data is fetched from the **backend API** and parsed.

3. Markers are created for each event using the **Mapbox SDK**.

4. Gestures are used to **detect taps** (show event details) and **long-presses** (create events).

5. User actions (confirm attendance, create event) are sent to the **backend API**.

## 🛠️ Getting Started
### Prerequisites
- Flutter SDK: [Install Flutter](https://docs.flutter.dev/get-started/install)
- Firebase account & credentials 
- Mapbox account & credentials 

### Installation
1. **clone this repo**:
```sh
git clone https://github.com/fatihmerickoc/miitti_app.git
cd miitti_app
```
2. **install dependencies**
```sh
flutter pub get
```

3. **run the app**
```sh
flutter run
```
## 📦 Built With
[Flutter](https://flutter.dev/) ~ the mobile framework

[Firebase](https://firebase.google.com/) ~ backend and database service (also used for push notificiations)

[Mapbox](https://www.mapbox.com/) ~  mapping and location service

[Riverpod](https://riverpod.dev/) ~ state management library

## 📜 License:
© 2024 Fatih Koc. All rights reserved. This code is the proprietary property of Fatih Koc. No part of this repository may be reproduced, distributed, or transmitted in any form or by any means, including photocopying, recording, or other electronic or mechanical methods, without the prior written permission of the owner, except for brief quotations in critical reviews and certain noncommercial uses permitted by copyright law. Usage for commercial purposes or within company settings is explicitly prohibited.












