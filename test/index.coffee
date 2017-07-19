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
                chai.expect(options.qs).to.deep.equal(part: 'snippet')
                chai.expect(options.headers['Authorization']).to.equal('Bearer auth_token')
                chai.expect(options.headers['Content-Length']).to.equal(100)
                chai.expect(options.multipart.chunked).to.equal(true)
                chai.expect(options.multipart.data[0]['Content-Type']).to.equal('application/json')
                chai.expect(options.multipart.data[1]['Content-Type']).to.equal('text/plain')
                snippet = videoId: 'video_id', name: 'caption_name', language: 'caption_language'
                chai.expect(options.multipart.data[0]['body'].snippet).to.deep.equal(snippet)
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
            response = statusCode: 400, error: message: 'contentRequired'
            yt.__set__ 'request': (options, callback) ->
                callback null, response, null

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

        it 'should return an error if response is 403', (done) ->
            response = statusCode: 403, error: message: 'forbidden'
            yt.__set__ 'request': (options, callback) ->
                callback null, response, null

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

        it 'should return an error if response is 404', (done) ->
            response = statusCode: 404, error: message: 'videoNotFound'
            yt.__set__ 'request': (options, callback) ->
                callback null, response, null

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

        it 'should return an error if response is 409', (done) ->
            response = statusCode: 404, error: message: 'captionExists'
            yt.__set__ 'request': (options, callback) ->
                callback null, response, null

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error) ->
                chai.expect(error).to.be.an.instanceof(Error)
                do done

        it 'should return successfully', (done) ->
            response = statusCode: 200
            yt.__set__ 'request': (options, callback) ->
                callback null, response, null

            yt.insert 'auth_token', 'video_id', 'caption_name', 'caption_file', 'caption_language', (error) ->
                chai.expect(error).to.be.not.instanceof(Error)
                do done
