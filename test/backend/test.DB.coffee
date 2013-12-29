assert = require('assert')
chai = require('chai')
expect = chai.expect

appUri = process.env.APP_URI

DB = require(appUri + '/server/DB')
client = require('redis').createClient()

describe 'DB - Redis Database Helper', ->
    database = 'test'

    describe '#set', ->
        it 'should set an key', (done) ->
            DB.set database, 'set1', 'foo', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal('OK')
                done()

        it 'should throw an error if no value is set', (done) ->
            DB.set database, 'set2', '', (err, res) ->
                expect(err).to.be.match(/^Error/)
                expect(res).to.be.null
                done()

    describe '#get', ->
        before ->
            client.set('key test:get1', 'foo')
            client.set('key test:get2', 'hah')
            client.del('key test:get3')

        it 'should get a key set by DB.set', (done) ->
            DB.get database, 'get1', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal('foo')
                done()

        it 'should get the key `key test:get2`', (done) ->
            DB.get database, 'get2', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal('hah')
                done()

        it 'should get a null value for undefined key', (done) ->
            DB.get database, 'get3', (err, res) ->
                expect(err).to.be.null
                expect(res).to.be.null
                done()

    describe '#del', ->
        removeKeys = ['del2', 'del3', 'del4']

        before ->
            client.set('key test:del1', 'foo')

            removeKeys.forEach (key) ->
                client.set("key test:#{key}", 'foo')

        it 'should delete a key set', (done) ->
            DB.del database, 'del1', (err, deleted) ->
                expect(err).to.be.null
                expect(deleted).to.equal(1)
                done()

        it 'should accept an array to delete multiple keys', (done) ->
            DB.del database, removeKeys, (err, deleted) ->
                expect(err).to.be.null
                expect(deleted).to.equal(3)
                done()

    describe '#hsave', ->
        before (done) ->
            client.hset('hash test:test', 'hsave7', 'foo', done)

        it 'should accept an object with a single property set', (done) ->
            DB.hsave database, 'test', {'hsave1':'foo'}, (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(1)
                done()

        it 'should not overwrite an already set property', (done) ->
            DB.hsave database, 'test', 'hsave7', 'foo', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(0)
                done()

        it 'should set an object with multiple properties set', (done) ->
            values =
                'hsave2': 'foo2'
                'hsave3': 'foo3'
                'hsave4': 'foo4'

            DB.hsave database, 'test', values, (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal('OK')
                done()

        it 'should accept a key value string pair', (done) ->
            DB.hsave database, 'test', 'hsave5', 'foo5', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(1)
                done()

        it 'should return an error when an empty object is sent', (done) ->
            DB.hsave database, 'test', {}, (err, res) ->
                expect(err).to.be.match(/^Error/)
                expect(res).to.be.null
                done()

        it 'should throw an error if arg3 (key) is a string and arg4 (val) is an object', (done) ->
            DB.hsave database, 'test', 'hsave6', [], (err, res) ->
                expect(err).to.be.match(/^Error/)
                expect(res).to.be.null
                done()

    describe '#hdel', ->
        before (done) ->
            client.hset 'hash test:hdel', 'hdel1', 'foo1'
            client.hdel 'hash test:hdel', 'hdel2', 'foo2'
            client.hset 'hash test:hdel', 'hdel3', 'foo3', done

        it 'should delete a single hash property', (done) ->
            DB.hdel database, 'hdel', 'hdel1', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(1)
                done()

        it 'should not delete an unset key', (done) ->
            DB.hdel database, 'hdel', 'hdel2', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(0)
                done()

        it 'should delete an entire hash', (done) ->
            DB.hdel database, 'hdel', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(1)
                done()

    after ->
        removeKeys = [
            'set1',
            'get1',
            'get2',
            'del1',
            'del2',
            'del3',
            'del4'
        ]

        removeKeys = removeKeys.map (key) ->
            return "key test:#{key}"

        client.del.apply(client, removeKeys)
        client.del('hash test:test')
        client.del('hash test:hdel')



