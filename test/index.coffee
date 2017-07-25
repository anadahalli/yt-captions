chai = require 'chai'
rewire = require 'rewire'

yt = rewire '../index.js'

describe 'yt-captions', () ->

    it 'should export a module function', () ->
        chai.assert.isFunction(yt.insert)

    describe 'parameter checks', () ->

        it 'should return an error if null auth_token is passed', (done) ->
            yt.insert null, null, null, null, null, (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

        it 'should return an error if null video_id is passed', (done) ->
            yt.insert 'auth_token', null, null, null, null, (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

        it 'should return an error if null caption_name is passed', (done) ->
            yt.insert 'auth_token', 'video_id', null, null, null, (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

        it 'should return an error if null caption_file is passed', (done) ->
            yt.insert 'auth_token', 'video_id', 'caption_name', null, null, (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

        it 'should return an error if null caption_language is passed', (done) ->
            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', null, (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

    describe 'file checks', () ->

        it 'should return an error if caption_file does not exist', (done) ->
            yt.__set__ 'fs.existsSync': (file) -> false

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

    describe 'request checks', () ->

        before () ->
            yt.__set__ 'fs.existsSync', (path) -> true
            yt.__set__ 'fs.statSync', (path) -> size: 100
            yt.__set__ 'fs.createReadStream', (path, options) -> path: path, bytesRead: 0

        it 'should have all the request options set', (done) ->
            yt.__set__ 'request': (options, callback) ->
                chai.expect(options.method).to.equal('POST')
                chai.expect(options.url).to.equal('https://www.googleapis.com/upload/youtube/v3/captions')

                qs = part: 'snippet', uploadType: 'multipart', alt: 'json'
                chai.expect(options.qs).to.deep.equal(qs)

                chai.expect(options.headers['Authorization']).to.equal('Bearer auth_token')
                chai.expect(options.headers['Content-Length']).to.equal(100)

                chai.expect(options.multipart.chunked).to.equal(true)
                chai.expect(options.multipart.data[0]['Content-Type']).to.equal('application/json')
                chai.expect(options.multipart.data[1]['Content-Type']).to.equal('text/plain')

                body = snippet: videoId: 'video_id', name: 'caption_name', language: 'caption_language'
                chai.expect(options.multipart.data[0]['body']).to.deep.equal(JSON.stringify(body))

                fs = yt.__get__ 'fs'
                stream = fs.createReadStream 'caption_file'
                chai.expect(options.multipart.data[1]['body']).to.deep.equal(stream)
                do done

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error) ->

        it 'should return an error if request fails', (done) ->
            yt.__set__ 'request': (options, callback) -> callback new Error

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

        it 'should return an error if response is 400', (done) ->
            body = error: code: 400, message: 'contentRequired'
            yt.__set__ 'request': (options, callback) ->
                callback null, statusCode: 400, body

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error, body) ->
                chai.expect(error).to.be.an.instanceof(Error)
                chai.expect(body.code).to.be.equal(400)
                do done

        it 'should return an error if response is 403', (done) ->
            body = error: code: 403, message: 'forbidden'
            yt.__set__ 'request': (options, callback) ->
                callback null, statusCode: 403, body

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error, body) ->
                chai.expect(error).to.be.an.instanceof(Error)
                chai.expect(body.code).to.be.equal(403)
                do done

        it 'should return an error if response is 404', (done) ->
            body = error: code: 404, message: 'videoNotFound'
            yt.__set__ 'request': (options, callback) ->
                callback null, statusCode: 404, body

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error, body) ->
                chai.expect(error).to.be.an.instanceof(Error)
                chai.expect(body.code).to.be.equal(404)
                do done

        it 'should return an error if response is 409', (done) ->
            body = error: code: 409, message: 'captionExists'
            yt.__set__ 'request': (options, callback) ->
                callback null, statusCode: 409, body

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error, body) ->
                chai.expect(error).to.be.an.instanceof(Error)
                chai.expect(body.code).to.be.equal(409)
                do done

        it 'should return successfully', (done) ->
            yt.__set__ 'request': (options, callback) ->
                callback null, statusCode: 200, null

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error) ->
                chai.expect(error).to.be.not.instanceof(Error)
                do done
