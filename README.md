# yt-captions

yt-captions - Insert captions to YouTube videos using [YouTube Data API](https://developers.google.com/youtube/v3/docs/captions/insert)

## Installation

```sh
npm install yt-captions
```

## Usage

```js
var yt = require('yt-captions');

var auth_token = 'ya29.GluMBA16G2sd0_BuEcT_kuwb-lemyUO1iEnA83NzUhBpl4qKaXN2TyNjME_Nm1zfGI92yyK2Ri03WOg1ZFw95URZCC0NIFuzLcs93JiiAeFtAm9Rmfmk7zWMt-Tg';

yt.insert(auth_token, 'M7FIvfx5J10', 'English', 'en_US', function(error) {
    if(error) {
        console.log(error.message);
    }
});
```

OAuth2 token with either of the following scope is required
```
https://www.googleapis.com/auth/youtube.force-ssl
https://www.googleapis.com/auth/youtubepartner
```

## Testing

```sh
npm install mocha
npm test
```

## Contributors

> Ashwath Nadahalli [@anadahalli](https://github.com/anadahalli)

Feel free to send your pull requests and contribute to this project

## License

MIT
