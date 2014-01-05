assert = require('assert')
chai = require('chai')
expect = chai.expect

appUri = process.env.APP_URI

DB = require(appUri + '/server/DB')
client = require('redis').createClient()

asyncObj = {}
asyncFinish = (type, expect, callback) ->
    asyncObj[type] = asyncObj[type] or 0

    do callback if ++asyncObj[type] is expect

keyValueGenerator = (prefix, length, offset = 0) ->
    keys = []
    values = Array(length + 1).join(0).split('').map (a,i) ->
        keys.push(offset + i)
        name: "#{prefix} - #{offset + i}"

    [keys, values]

zaddBuilder = (keys, values) ->
    newArr = []
    keys.forEach (key, index) ->
      newArr.push(key, JSON.stringify(values[index])) if values[index]?

    return newArr

describe 'DB - Redis Database Helper', ->
    database = 'test'

    before (done) ->
        client.del('hash test:hgetAll', done)

    describe '#set', ->
        it 'should set an key', (done) ->
            DB.set database, 'set1', 'foo', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal('OK')
                do done

        it 'should throw an error if no value is set', (done) ->
            DB.set database, 'set2', '', (err, res) ->
                expect(err).to.be.match(/^Error/)
                expect(res).to.be.null
                do done

        after ->
            client.del('key test:set1')

    describe '#get', ->
        before ->
            client.set('key test:get1', 'foo')
            client.set('key test:get2', 'hah')
            client.del('key test:get3')

        it 'should get a key set by DB.set', (done) ->
            DB.get database, 'get1', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal('foo')
                do done

        it 'should get the key `key test:get2`', (done) ->
            DB.get database, 'get2', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal('hah')
                do done

        it 'should get a null value for undefined key', (done) ->
            DB.get database, 'get3', (err, res) ->
                expect(err).to.be.null
                expect(res).to.be.null
                do done

        after ->
            client.del('key test:get1')
            client.del('key test:get2')

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
                do done

        it 'should accept an array to delete multiple keys', (done) ->
            DB.del database, removeKeys, (err, deleted) ->
                expect(err).to.be.null
                expect(deleted).to.equal(3)
                do done

        after ->
            client.del('key test:del1')
            client.del('key test:del2')
            client.del('key test:del3')
            client.del('key test:del4')

    describe '#hsave', ->
        before (done) ->
            client.hset('hash test:test', 'hsave7', 'foo', done)

        it 'should accept an object with a single property set', (done) ->
            DB.hsave database, 'test', {'hsave1':'foo'}, (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(1)
                do done

        it 'should not overwrite an already set property', (done) ->
            DB.hsave database, 'test', 'hsave7', 'foo', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(0)
                do done

        it 'should set an object with multiple properties set', (done) ->
            values =
                'hsave2': 'foo2'
                'hsave3': 'foo3'
                'hsave4': 'foo4'

            DB.hsave database, 'test', values, (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal('OK')
                do done

        it 'should accept a key value string pair', (done) ->
            DB.hsave database, 'test', 'hsave5', 'foo5', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(1)
                do done

        it 'should return an error when an empty object is sent', (done) ->
            DB.hsave database, 'test', {}, (err, res) ->
                expect(err).to.be.match(/^Error/)
                expect(res).to.be.null
                do done

        it 'should throw an error if arg3 (key) is a string and arg4 (val) is an object', (done) ->
            DB.hsave database, 'test', 'hsave6', [], (err, res) ->
                expect(err).to.be.match(/^Error/)
                expect(res).to.be.null
                do done

        after ->
            client.del('hash test:test')

    describe '#hdel', ->
        before (done) ->
            callback = asyncFinish.bind(null, 'hdel', 3, done)
            client.hset('hash test:hdel', 'hdel1', 'foo1', callback)
            client.hdel('hash test:hdel', 'hdel2', 'foo2', callback)
            client.hset('hash test:hdel', 'hdel3', 'foo3', callback)

        it 'should delete a single hash property', (done) ->
            DB.hdel database, 'hdel', 'hdel1', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(1)
                do done

        it 'should not delete an unset key', (done) ->
            DB.hdel database, 'hdel', 'hdel2', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(0)
                do done

        it 'should delete an entire hash', (done) ->
            DB.hdel database, 'hdel', (err, res) ->
                expect(err).to.be.null
                expect(res).to.equal(1)
                do done

        after ->
            client.del('hash test:hdel')

    describe '#hgetAll', ->
        before (done) ->
            callback = asyncFinish.bind(null, 'hdel', 4, done)
            client.hset('hash test:hgetAll', 'hgetAll1', 'foo1', callback)
            client.hset('hash test:hgetAll', 'hgetAll2', 'foo2', callback)
            client.hset('hash test:hgetAll', 'hgetAll3', 'foo3', callback)
            client.hset('hash test:hgetAll', 'hgetAll4', 'foo4', callback)

        it 'should return 3 values', (done) ->
            DB.hgetAll database, 'hgetAll', ['hgetAll1', 'hgetAll2', 'hgetAll3'], (err, res) ->
                expect(err).to.be.null
                expect(res).to.be.an('array')
                expect(res).to.have.length(3)
                expect(res[0]).to.equal('foo1')
                expect(res[1]).to.equal('foo2')
                expect(res[2]).to.equal('foo3')
                do done

        it 'should return 3 values (1 being null)', (done) ->
            DB.hgetAll database, 'hgetAll', ['hgetAll1', 'hgetAll1000', 'hgetAll3'], (err, res) ->
                expect(err).to.be.null
                expect(res).to.be.an('array')
                expect(res).to.have.length(3)
                expect(res[0]).to.equal('foo1')
                expect(res[1]).to.be.null
                expect(res[2]).to.equal('foo3')
                do done

        it 'should return all values from a hash key', (done) ->
            DB.hgetAll database, 'hgetAll', (err, res) ->
                expect(err).to.be.null
                expect(res).to.be.an('object')
                expect(res).to.have.keys(['hgetAll1', 'hgetAll2', 'hgetAll3', 'hgetAll4'])
                do done

        it 'should throw an error when called without a callback', ->
            expect(DB.hgetAll.bind(DB, database, 'hgetAll')).to.throw(Error)

        after ->
            client.del('hash test:hgetAll')

    describe '#zadd', ->
        overwriteLength = 3

        before (done) ->
            args = zaddBuilder.apply(null, keyValueGenerator('zadd2', overwriteLength, 1000))
            args.unshift('zset test:zadd')
            args.push(done)
            client.zadd.apply(client, args)

        it 'should accept 2 arrays of keys/values to insert in the database', (done) ->
            length = 4
            [keys, values] = keyValueGenerator('zadd1', length, 2000)
            DB.zadd database, 'zadd', keys, values, (err, res) ->
                expect(err).to.be.null
                expect(res).to.have.equal(length)
                do done

        it 'should not overwrite preexisting keys', (done) ->
            [keys, values]= keyValueGenerator('zadd2', overwriteLength, 1001)
            DB.zadd database, 'zadd', keys, values, (err, res) ->
                expect(err).to.be.null
                expect(res).to.have.equal(1)
                do done

        after ->
            client.zremrangebyrank('zset test:zadd', 0, -1)

        



