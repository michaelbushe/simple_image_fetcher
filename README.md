# Image Fetcher
A simple on-page image fetching app with polish.

Video Links:
[iOS](https://drive.google.com/file/d/1pj3sTtWlPtWwYSRYqsxD5dndbEcvRkNt/view?usp=sharing)
[Android](https://drive.google.com/file/d/1dOisOV0YwbpQ-6ebePG4AsOOPfCwQsRn/view?usp=sharing)

## Featues
- Coordinated animations
- Fast determination of background color from the picture. Trades off speed for fidelity - longer pixel sampling 
  would result in better colors. 
- Image clipped to a rounded square for a clean professional look.
- Adapts to screen rotation and different sized screens.
- Semantics, including announcing image load and error on supported platforms
- Settings for dark/light theme (this was outside the spec but a convenience for theme switching.  Yes, it could be removed and use the system theme.)
- Nifty wave spinner
- Launcher icon
- Splash screen
- Adaptive to iOS and Android for looks and sizing.  Follows Material and HIG guidelines. No magic numbers.
- Uses a Cupertino button on iOS since Material buttons look out of place on iOS.
- Uses the latest and greatest Material 3 button on Android and non-iOS platforms.
- Proper widget keys for fast rebuilds (and fast development)
- Proper code structure
  - Each drawn widget is a stateless widget, can be used independently
  - The main page is only responsible for layout out the stateless widgets
  - Service is separated from the widgets.
  - Uses Signals for state management - a forward-looking choice. Signals is being built into the Dart SDK, it is
    already the default for Angular.  I expect Signals to be the go-to choice, over Riverpod, BLoC,
    etc. for Flutter state management
  - Widgets only depend on the ImageState
  
Notes: 
- There's no icon on the button, no app title, etc. Does not go beyond the requirements, stays simple.
- Since the images are from a small set, the API should send the background color with the imageURL, calculating the 
  colors at build or server start time.

## Goal (provided from a third-party source)
Build a tiny mobile app that fetches a random image from an API and displays it centered as a square. 
A button should fetch a new image. 
The background should adapt to the image’s colors for an immersive effect.

## API
Use the GET /image endpoint described in Swagger:
https://november7-730026606190.europe-west1.run.app/docs#/default/get_random_image_image__get

**Example Response:**

`{"url": "https://images.unsplash.com/photo-1506744038136-46273834b3fb"}`

**Notes:**
1. CORS is enabled server-side.
2. Image URLs are from Unsplash; treat them as large, remote images (use caching/placeholder strategies).

## Requirements

1. Single screen UI
* Square image centered on screen
* Background color adapts to the image
* A button labeled “Another” below the image loads a new image.

2. Fetching
* Tapping the button triggers a new GET /image, updates the image.
* Show a loading state while fetching
* Handle errors gracefully

3. Polish
* Smooth transitions (fade image in; animate background color change).
* Respect light/dark mode.
* Basic accessibility
