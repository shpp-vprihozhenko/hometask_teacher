const MongoClient = require('mongodb').MongoClient;
const ObjectID = require('mongodb').ObjectID;
const uri = "mongodb://localhost:27017";
const client = new MongoClient(uri, {useNewUrlParser: true, useUnifiedTopology: true});

let usersCol;

client.connect(err => {
	console.log('cb of connect');
	if (err) {
		console.error('some err on connect to db', err);
		return;
	}
	
	col = client.db("homeTasks").collection("pupils");

	col.find().toArray((err,ar)=>{
		console.log('homeTasksCol');
		console.table(ar);
	});
	
	return;
	
	сolCat1 = client.db("chastnik").collection("cat1");

	сolCat1.find().toArray((err,ar)=>{
		console.log('\nсolCat1');
		console.table(ar);
	});
	
	return;
	
	сolCat2 = client.db("chastnik").collection("cat2");
	colRSS = client.db("chastnik").collection("rss");
	usersCol = client.db("chastnik").collection("users");

	/*
	colRSS.find().toArray((err,ar)=>{
		console.log('\ncolRSS');
		console.table(ar);
	});
	*/
	/*
	colRSS.insertOne({dt: new Date(), author: 'Владимир', msg: 'Добавлена подкатегория Легковых авто', servId: '', city: 'Одесса'}, (err, newRSS)=>{
		if (err) {
			console.log('Ошибка при создании newRSS(', err);
		} else {
			console.log('newCat', newRSS.insertedId);
		}
	});
	*/

  return
	/*
	сolCat2.deleteMany({}, (err, result)=>{
		if(err){
			console.log('Error on del.', err);
		} else {
			console.log('ok del');
		}
	});
	return
	*/

	/*
	сolCat2.insertOne({cat1id: '5dd5a44ac9f8e60f2cc9182b', cat2: 'Легковых авто'}, (err, newCat)=>{
		if (err) {
			console.log('Ошибка при создании cat2(', err);
		} else {
			console.log('newCat',newCat); //.insertedId
		}
	});
	сolCat2.insertOne({cat1id: '5dd5a44ac9f8e60f2cc9182b', cat2: 'Грузовых авто'}, (err, newCat)=>{
		if (err) {
			console.log('Ошибка при создании cat2(', err);
		} else {
			console.log('newCat',newCat); //.insertedId
		}
	});
	сolCat2.insertOne({cat1id: '5dd5a4a8fa8a021aec559446', cat2: 'Легковых авто'}, (err, newCat)=>{
		if (err) {
			console.log('Ошибка при создании cat2(', err);
		} else {
			console.log('newCat',newCat); //.insertedId
		}
	});
	сolCat2.insertOne({cat1id: '5dd5a4a8fa8a021aec559446', cat2: 'Грузовых авто'}, (err, newCat)=>{
		if (err) {
			console.log('Ошибка при создании cat2(', err);
		} else {
			console.log('newCat',newCat); //.insertedId
		}
	});
	*/
	сolCat1.insertOne({cat: 'Обслуживание'}, (err, newCat1)=>{
		if (err) { console.log('Ошибка при создании cat1(', err) }
		else {
			console.log('ok ins Cat1 id', newCat1.insertedId)
			сolCat2.insertOne({cat1id: newCat1.insertedId, cat2: 'Грузовых авто'}, (err, newCat2)=>{
				if (err) { console.log('Ошибка при создании cat2(', err)
				} else { console.log('ok ins Cat2', newCat2.insertedId) }
			});
			сolCat2.insertOne({cat1id: newCat1.insertedId, cat2: 'Легковых авто'}, (err, newCat2)=>{
				if (err) { console.log('Ошибка при создании cat2(', err)
				} else { console.log('ok ins Cat2', newCat2.insertedId) }
			});
		}
	});
	сolCat1.insertOne({cat: 'Ремонт'}, (err, newCat1)=>{
		if (err) { console.log('Ошибка при создании cat1(', err) }
		else {
			console.log('ok ins Cat1 id', newCat1.insertedId)
			сolCat2.insertOne({cat1id: newCat1.insertedId, cat2: 'Грузовых авто'}, (err, newCat2)=>{
				if (err) { console.log('Ошибка при создании cat2(', err)
				} else { console.log('ok ins Cat2', newCat2.insertedId) }
			});
			сolCat2.insertOne({cat1id: newCat1.insertedId, cat2: 'Легковых авто'}, (err, newCat2)=>{
				if (err) { console.log('Ошибка при создании cat2(', err)
				} else { console.log('ok ins Cat2', newCat2.insertedId) }
			});
			сolCat2.insertOne({cat1id: newCat1.insertedId, cat2: 'Квартир'}, (err, newCat2)=>{
				if (err) { console.log('Ошибка при создании cat2(', err)
				} else { console.log('ok ins Cat2', newCat2.insertedId) }
			});
			сolCat2.insertOne({cat1id: newCat1.insertedId, cat2: 'Телефонов'}, (err, newCat2)=>{
				if (err) { console.log('Ошибка при создании cat2(', err)
				} else { console.log('ok ins Cat2', newCat2.insertedId) }
			});
		}
	});
	сolCat1.insertOne({cat: 'Реставрация'}, (err, newCat1)=>{
		if (err) { console.log('Ошибка при создании cat1(', err) }
		else {
			console.log('ok ins Cat1 id', newCat1.insertedId)
			сolCat2.insertOne({cat1id: newCat1.insertedId, cat2: 'Автомобилей'}, (err, newCat2)=>{
				if (err) { console.log('Ошибка при создании cat2(', err)
				} else { console.log('ok ins Cat2', newCat2.insertedId) }
			});
			сolCat2.insertOne({cat1id: newCat1.insertedId, cat2: 'Зданий'}, (err, newCat2)=>{
				if (err) { console.log('Ошибка при создании cat2(', err)
				} else { console.log('ok ins Cat2', newCat2.insertedId) }
			});
		}
	});

	usersCol.insertOne({email: 'test1@gmail.com', pwd: '12345', name: 'Stasik'}, (err, newUser)=>{
		if (err) {
			err = 'Ошибка при создании пользователя(';
			res.send(JSON.stringify({err: err, newId: undefined}));
		} else {
			console.log('newUser ID', newUser.insertedId);
		}
	});


	/*
	usersCol.find({}).toArray((err,arUsers)=>{
		console.table(arUsers);
	});
	*/

	сolCat1.find().toArray((err,ar)=>{
		console.log('\ncolCat1');
		console.table(ar);
		/*
		for (let el of ar) {
			let c1id = el._id;
			console.log('1',c1id, typeof c1id);

			сolCat2.insertOne({cat1id: c1id, cat2: 'Легковых авто'}, (err, newCat)=>{
				if (err) {
					console.log('Ошибка при создании cat2(', err);
				} else {
					console.log('newCat',newCat); //.insertedId
				}
			});
			сolCat2.insertOne({cat1id: c1id, cat2: 'Грузовых авто'}, (err, newCat)=>{
				if (err) {
					console.log('Ошибка при создании cat2(', err);
				} else {
					console.log('newCat',newCat); //.insertedId
				}
			});
		}
		*/
	});

	сolCat2.find().toArray((err,ar)=>{
		console.log('\ncolCat2');
		console.table(ar);
	});

	сolCat1.aggregate([
    { $lookup:
       {
         from: 'cat2',
         localField: '_id',
         foreignField: 'cat1id',
         as: 'cat2'
       }
     }
    ]).toArray(function(err, res) {
		if (err) throw err;
		console.log(JSON.stringify(res));
	})
});
