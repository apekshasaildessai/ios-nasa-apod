# ios-nasa-apod
An iOS app that displays NASA's Astronomy Picture of the Day(APOD). 

Application Features: 
The application will display today's Astronomy Picture along with its date, title and description. Users can also search picture for a day of their choice.
Tap on the image to view the HD image which can be zoomed in and panned by the user. If it's a Youtube video, it will open in a new view where users can choose to play it.
Users create/manage collection of "favorite" listings by tapping the "star" icon
All Favorites images/videos will be displayed on the favorites page, accessed using the favorites icon on the bottom right corner.
Users also search picture for a day of their choice by clicking the calendar icon on the bottom left corner.
The app caches the viewed and favorited picture details which can be viewed in offline mode. 
Also show latest save Picture on app launch in case of Network issue.


Extra Credits
Supports all sizes and orientations for both iPads and iPhones
The application works with Dark mode, mainly uses system color, and assets have icons for light and dark mode .


Technological Features:
Calls NASA's open APIs https://api.nasa.gov/ APOD(Astronomy Picture of the Day) to get the resource
Uses CoreData to save APOD details to disk
Images are download and saved on disk
Uses YouTube-Player-iOS-Helper library to play the youtube videos 

**Design choices:**
Nowadays, phones are getting bigger, hence the design choice to add most of the buttons on the bottom for each reachability.
Check the below mockup wireframes for the initial design. Most of the buttons (back buttons) are placed on the bottom for each reachability.

**Mockups:**
![App-Mockup](https://user-images.githubusercontent.com/16442328/155944283-d275ccd0-79e3-488e-97cb-2392e0f078de.jpg)


Screenshots
**iPhone Dark mode:**

![Screenshot-iPhone-darkMode](https://user-images.githubusercontent.com/16442328/155944284-17ea78f3-9c03-422e-bad5-25263c4f9b43.png)


**iPhone Light mode:**

![Screenshot-iPhone-lightMode](https://user-images.githubusercontent.com/16442328/155944265-cb852b84-6988-4091-8169-7c50df0eceee.png)

**iPad:**

![Screenshot-iPad](https://user-images.githubusercontent.com/16442328/155944270-80aa576d-06a3-49f6-8457-aeb30bc7d689.png)


