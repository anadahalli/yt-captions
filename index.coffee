
fs = require 'fs'
request = require 'request'

insert = (auth_token, video_id, caption_name, caption_file, caption_language, callback) ->

    return callback new Error('Invalid auth_token') if not auth_token
    return callback new Error('Invalid video_id') if not video_id
    return callback new Error('Invalid caption_name') if not caption_name
    return callback new Error('Invalid caption_file') if not caption_file
    return callback new Error('Invalid caption_language') if not caption_language

    return callback new Error('Caption file not found') if not fs.existsSync(caption_file)

    body =
        snippet:
            videoId: video_id
            name: caption_name
            language: caption_language

    options =
        method: 'POST'
        url: 'https://www.googleapis.com/upload/youtube/v3/captions'
        qs: part: 'snippet'
        headers:
            'Authorization': "Bearer #{auth_token}"
            'Content-Length': fs.statSync(caption_file).size
        multipart:
            chunked: true
            data: [
                {
                    'Content-Type': 'application/json'
                    body: JSON.stringify body
                }, {
                    'Content-Type': 'text/plain'
                    body: fs.createReadStream caption_file
                }
            ]
        json: true

    request options, (error, response, body) ->
        return callback error if error?

        return callback new Error(body.error.message) if response.statusCode != 200
        
        return callback()

module.exports = insert: insert
