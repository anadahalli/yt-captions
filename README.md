# yt-captions

yt-captions - Insert captions to YouTube videos using [YouTube Data API](https://developers.google.com/youtube/v3/docs/captions/insert)

## Installation

```sh
npm install yt-captions
```

## Usage

```js
var yt = require('yt-captions');

yt.insert('', 'M7FIvfx5J10', 'English', 'en_US', function(error) {
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
