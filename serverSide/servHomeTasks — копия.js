const cPathToSaveTaskImages = 'tasks_images/';
const cPathToSavePupilImages = 'tasks_sol_images/';

const express = require("express");
const bodyParser = require("body-parser");
const fs = require("fs");
const MongoClient = require('mongodb').MongoClient;
const ObjectID = require('mongodb').ObjectID;

const uri = "mongodb://localhost:27017";
const client = new MongoClient(uri, {useNewUrlParser: true, useUnifiedTopology: true});

client.connect(err => {
	console.log('mongo client connect');
	if (err) {
		console.error('some err on connect to mongo', err);
		res.send(err);
		return;
	} else {
		console.log('connected!');
	}
});


var app = express();

app.use(bodyParser.urlencoded({ extended: true, limit: "50mb" }));
app.use(express.json());
app.use(function(req, res, next) {
  console.log('\n\nInc Req at', 'p', req.url, req.method);
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

app.listen(6613, function () {
  console.log('6613 listening');
});


app.post('/add_task', function (req, res) {
	console.log('add_task body',req.body);

	if (!req.body.taskDescription) {
		console.log('Ошибка при add_task(');
		res.send('err. no task description to add');
		return;
	}

	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("tasks");

		homeTasksCol.insertOne(req.body, (err, newTask)=>{
			if (err) {
				console.log('Ошибка при создании newTask(', err) 
				res.send(err);
			} else {
				console.log('ok ins newTask id', newTask.insertedId);
				res.send("OK " + newTask.insertedId);
			}
		});
	});
});

app.post('/update_task', function (req, res) {
  console.log('update_task body',req.body);
    
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("tasks");
		
		let newValues = { $set: { lesson: req.body.lesson, taskDescription: req.body.taskDescription, dtDeadline: req.body.dtDeadline } };

		homeTasksCol.updateOne({_id: ObjectID(req.body._id)}, newValues, function(err) {
			if (err) {
				console.log("some err on update", err);
				res.send('error on update '+err);				
			} else {
				console.log("record updated");
				res.send('OK');
			}
		});
	});
});

app.post('/uploadImage', function (req, res) {
	console.log('uploadImage ', req.body.id, req.body.name);

	let _id = req.body.id;
	let name = conv2Eng(req.body.name);
	console.log('got name', name);
	
	var img = req.body.image;
	var realFile = Buffer.from(img,"base64");
	fs.writeFile(cPathToSaveTaskImages + name, realFile, function(err) {
		if(err) {
			console.log(err);			
		} else {
			console.log('image written to disk', name);
		}
	});
	
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("tasks");
		
		homeTasksCol.updateOne({_id: ObjectID(_id)}, { $push: { taskFileName: name } }, function(err) {
			if (err) {
				console.log("some err on update", err);
				res.send('error on update '+err);				
			} else {
				console.log("record updated");
				res.send('OK');
			}
		});
	});
});

app.post('/delImage', function (req, res) {
	console.log('delImage ', req.body.id, req.body.name);

	let _id = req.body.id;
	let name = req.body.name;
	console.log('got name to del', name);
	
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("tasks");
		
		homeTasksCol.updateOne({_id: ObjectID(_id)}, { $pull: { taskFileName: name } }, function(err) {
			if (err) {
				console.log("some err on del img", err);
				res.send('error on del img '+err);				
			} else {
				console.log("record deleted");
				res.send('OK');
				fs.unlink(cPathToSaveTaskImages + name, (err)=>{});
			}
		});
	});
});

app.post('/loadImagesList', function (req, res) {
	console.log('loadImagesList for', req.body.id);

	let _id = req.body.id;

	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("tasks");
		
		homeTasksCol.find( { _id: ObjectID(_id) } ).toArray((err, ar)=>{
			if (err) {
				console.log('some err on got homeTasks ', err);			
				res.send(err);
			} else {
				console.log('got homeTasksCol ', ar.length);
				arFiles = [];
				ar.forEach( el =>{
					if (el.taskFileName) {
						el.taskFileName.forEach(name => {
							console.log('fn to send', name);
							arFiles.push(name);
						});
					}
				});
				res.send(JSON.stringify({err, arFiles}));
			}
		});
	});
});

app.post('/loadImage', function (req, res) {
	console.log('loadImage', req.body.fileName);

	let fileName;
	
	if (req.body.mode == 'solution') {
		fileName = cPathToSavePupilImages + req.body.fileName;			
	} else {
		fileName = cPathToSaveTaskImages + req.body.fileName;		
	}
	
	console.log('read fileName', fileName);

	let data = fs.readFileSync(fileName);
	let buf = new Buffer(data).toString('base64');
	//console.log('sending data', buf.substr(0,100));
	
	res.send(buf);
	console.log('file sent');
});

app.post('/arch_task', function (req, res) {
  console.log('arch_task body',req.body);
      	
	let id = req.body.id;
	if (!id) {
		console.log('err. No ID on req body found');
		res.send('err. no id');
		return;
	}
	
	let mode = req.body.mode;
	
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("tasks");

		homeTasksCol.updateOne({_id: ObjectID(id)}, {$set: {isArchive: mode}}, (err, task)=>{
			if (err) { 
				console.log('Ошибка при arch_task(', err) 
				res.send(err);
			} else {
				console.log('ok on change state', id);
				res.send("OK");
			}
		});
	});
			
})

app.post('/del_task', function (req, res) {
  console.log('del_task body',req.body);
      	
	let idToDel = req.body.id;
	if (!idToDel) {
		console.log('err. No ID on req body found');
		res.send('err. no id');
		return;
	}
	
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("tasks");

		homeTasksCol.deleteOne({_id: ObjectID(idToDel)}, (err, task)=>{
			if (err) { 
				console.log('Ошибка при создании newTask(', err) 
				res.send(err);
			} else {
				console.log('ok on del id', idToDel);
				res.send("OK");
			}
		});
	});
			
})

app.post('/hometasks', function (req, res) {
  console.log('hometasks body', req.body);
	let filter = {};
    if (req.body.filter) {
		if (req.body.filter == 'activeOnly') {
			filter = {isArchive: { $ne: true }};
		} else if (req.body.filter == 'archiveOnly') {
			filter = {isArchive: true };
		}
	}
	/*
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		*/
		homeTasksCol = client.db("homeTasks").collection("tasks");

		homeTasksCol.find( filter ).toArray((err, ar)=>{
			if (err) {
				console.log('some err on got homeTasks ', err);			
				res.send(err);
			} else {
				console.log('got homeTasksCol ', ar.length);			
				res.send(JSON.stringify({err, ar}));
			}
		});
	//});
	
})


// pupils

app.post('/getPupils', function (req, res) {
  console.log('getPupils body', req.body);
	let filter = {};
	try {
		filter = {city: req.body.city, school: req.body.school, classRoom: req.body.classRoom};
	} catch(e) {
		res.send(e);
		return;
	}
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		let col = client.db("homeTasks").collection("pupils");

		col.find( filter ).toArray((err, ar)=>{
			if (err) {
				console.log('some err on got pupils ', err);			
				res.send(err);
			} else {
				console.log('got pupils ', ar.length);			
				res.send(JSON.stringify({err, ar}));
			}
		});
	});
})

app.post('/add_pupil', function (req, res) {
	console.log('add_pupil body',req.body);

	if (!req.body.fio) {
		console.log('Ошибка при add_pupil( Нет ФИО!');
		res.send('err. no pupil data to add');
		return;
	}

	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("pupils");

		homeTasksCol.insertOne(req.body, (err, newPupil)=>{
			if (err) {
				console.log('Ошибка при создании newPupil(', err) 
				res.send(err);
			} else {
				console.log('ok ins newTask id', newPupil.insertedId);
				res.send("OK " + newPupil.insertedId);
			}
		});
	});

});

app.post('/updatche_pupil', function (req, res) {
  console.log('update_pupil body',req.body);
    
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("pupils");
		
		let newValues = { $set: { fio: req.body.fio, password: req.body.password } };

		homeTasksCol.updateOne({_id: ObjectID(req.body._id)}, newValues, function(err) {
			if (err) {
				console.log("some err on update", err);
				res.send('error on update '+err);				
			} else {
				console.log("record updated");
				res.send('OK');
			}
		});
	});
});

app.post('/check_pupil', function (req, res) {
	console.log('check_pupil body',req.body);

	if (!req.body.fio) {
		console.log('Ошибка при check_pupil( Нет ФИО!');
		res.send('err. no pupil data to check');
		return;
	}

	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("pupils");

		homeTasksCol.findOne(
			{city: req.body.city, school: req.body.school, classRoom: req.body.classRoom, fio: req.body.fio}
			, (err, pupil)=>{
				if (err) {
					res.send(err);
				} else {
					console.log('found pupil data', pupil);
					if (!pupil) {
						res.send("err");												
					}
					if (pupil.password == req.body.password) {
						console.log('password ok')
						res.send("OK " + pupil._id);
					} else {
						console.log('password wrong')
						res.send("err");						
					}
				}
			});
	});

});

// pupil's task

app.post('/uploadPupilImage', function (req, res) {
	console.log('uploadPupilImage ', req.body.id, req.body.name);

	let taskId = req.body.taskId;
	let pupilId = req.body.pupilId;
	let fname = req.body.name;
	
	console.log('got taskId', taskId, 'pupilId', pupilId, 'fname', fname);
	
	var img = req.body.image;
	var realFile = Buffer.from(img,"base64");

	fs.writeFile(cPathToSavePupilImages + fname, realFile, function(err) {
		if(err) {
			console.log(err);			
		} else {
			console.log('image written to disk', fname);
		}
	});

	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		
		col = client.db("homeTasks").collection("pupilSolvedTasks");
		
		col.find({ taskId, pupilId }).toArray((err,ar)=>{
			if (ar.length > 0) {
				col.updateOne({ taskId, pupilId }, { $push: { files: fname } }, function(err) {
					if (err) {
						console.log("some err on update", err);
						res.send('error on update '+err);				
					} else {
						console.log("record updated");
						res.send('OK');
					}
				});				
			} else {
				let arFiles = []; arFiles.push(fname);
				col.insertOne({ taskId, pupilId, files: arFiles }, (err, newTask)=>{
					if (err) {
						console.log('Ошибка при создании pupilSolvedTasks(', err) 
						res.send(err);
					} else {
						console.log('ok ins pupilSolvedTasks id', newTask.insertedId);
						res.send("OK " + newTask.insertedId);
					}
				});
			}
		});

	});
});

app.post('/updateImage', function (req, res) {
	console.log('updateImage ', req.body.type, req.body.name);

	let fileName = req.body.name;
	let type = req.body.type;
	
	console.log('got type', type, 'fn', fileName);
	
	var img = req.body.image;
	var realFileData = Buffer.from(img, "base64");

	let _path = (type == 'solution'? cPathToSavePupilImages : cPathToSaveTaskImages);
	console.log('_path', _path);
	
	fs.writeFile(_path + fileName, realFileData, function(err) {
		if(err) {
			console.log(err);			
			res.send('err '+err);
		} else {
			console.log('image written to disk', fileName);
			res.send('OK');
		}
	});
});


app.post('/getPupilSolvedTaskData', function (req, res) {
	console.log('getPupilSolvedTaskData', req.body.id, req.body.name);

	let taskId = req.body.taskId;
	let pupilId = req.body.pupilId;
	
	console.log('got taskId', taskId, 'pupilId', pupilId);
	
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		
		col = client.db("homeTasks").collection("pupilSolvedTasks");
		
		col.find({ taskId, pupilId }).toArray((err,ar)=>{
			if (err) {
				console.log('got err', err);
				res.send(err);
				return;
			}
			console.log('got', ar);
			res.send(JSON.stringify({data: ar[0]}));
		});

	});
});

app.post('/markPupilSolvedTask', function (req, res) {
	console.log('markPupilSolvedTask', req.body.id, req.body.name);

	let _id = req.body.id;
	
	let mark = 0;
	
	try {
		mark = parseInt(req.body.mark);
	} catch (e) {
		console.log('some err on parse mark', e);
	}
	
	if (mark == 0) {
		console.log('err. no mark(');
		res.send('Err. No mark');
		return;
	}
	
	console.log('got params for marking solvedTaskId', _id, 'mark', mark);
	
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		
		col = client.db("homeTasks").collection("pupilSolvedTasks");
		
		col.updateOne({ _id: ObjectID(_id) }, {$set: {mark}}, (err, task)=>{
			if (err) { 
				console.log('Ошибка при markPupilTask(', err) 
				res.send(err);
			} else {
				console.log('ok on markPupilTask');
				res.send("OK");
			}
		});
	});
});

app.post('/markPupilTaskAsSolved', function (req, res) {
	console.log('markPupilTaskAsSolved', req.body);

	let taskId = req.body.taskId;
	let pupilId = req.body.pupilId;
	
	if (!taskId || !pupilId) {
		console.log('no required parameters');
		res.send('no required parameters');
		return;
	}
	
	console.log('got taskId', taskId, 'pupilId', pupilId);
	
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		
		col = client.db("homeTasks").collection("pupilSolvedTasks");
		
		col.find({ taskId, pupilId }).toArray((err,ar)=>{
			if (ar.length > 0) {
				col.updateOne({ taskId, pupilId }, {$set: {isSolved: true}}, (err, task)=>{
					if (err) { 
						console.log('Ошибка при markPupilTaskAsSolved(', err) 
						res.send(err);
					} else {
						console.log('ok on markPupilTaskAsSolved');
						res.send("OK");
					}
				});
			} else {
				col.insertOne({ taskId, pupilId, isSolved: true }, (err, newTask)=>{
					if (err) {
						console.log('Ошибка при создании pupilSolvedTasks(', err) 
						res.send(err);
					} else {
						console.log('ok ins pupilSolvedTasks id', newTask.insertedId);
						res.send("OK");
					}
				});	
			}
		});
	});
});

app.post('/getPupilTasks', function (req, res) {
  console.log('getPupilTasks body', req.body);
    if (!req.body.city) {
		console.error('err. No required parameters');
		res.send('err. No required parameters');
		return;
	}

	let params = req.body;

	let filter = {};
	filter.isArchive = params.arcMode=='true'? true : { $ne: true };
	filter.city = params.city;
	filter.school = params.school;
	filter.classRoom = params.classRoom;
	
	console.log('got filter', filter);
	
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("tasks");
		
		homeTasksCol.find( filter ).toArray((err, ar)=>{
			if (err) {
				console.log('some err on got homeTasks ', err);			
				res.send(err);
			} else {
				console.log('got homeTasksCol ', ar.length);
				res.send(JSON.stringify({err, ar}));
			}
		});
	});
	
})

//{"taskId":"5fa2b69f8f202d2bd08ef265","pupilsId":["5f9f1a0e020485aa186d781c","5f9f1a5a020485aa186d781d","5f9f1ad4020485aa186d781e"]}

app.post('/getTasksStatus', function (req, res) {
  console.log('getTasksStatus body', req.body);

	let pupilId = req.body.pupilId;

    if (!pupilId) {
		console.error('err. No required parameters');
		res.send('err. No required parameters');
		return;
	}


	let filter = {};
	filter.pupilId = pupilId;
	
	let arTasksId = req.body.tasksId;
	console.log('got arTasksId', arTasksId);
	if (arTasksId) {
		filter.taskId = { $in: JSON.parse(arTasksId) }
	}
	
	console.log('got filter', filter);
	
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		col = client.db("homeTasks").collection("pupilSolvedTasks");
		
		col.find( filter ).toArray((err, ar)=>{
			if (err) {
				console.log('some err on get pupilSolvedTasks ', err);			
				res.send(err);
			} else {
				console.log('got pupilSolvedTasks ', ar.length);
				console.log('got pupilSolvedTasks ', ar);
				
				let arTaskStatus = [];
				ar.forEach(el=>{
					stateEl = {};
					stateEl.taskId = el.taskId;
					stateEl.status = '';
					if (el.mark) {
						stateEl.status = el.mark;
					} else if (el.isSolved) {
						stateEl.status = '-';
					}
					arTaskStatus.push(stateEl);
				});
				res.send(JSON.stringify({err, arTaskStatus}));
			}
		});
	});
	
})

app.post('/getPupilsTaskStates', function (req, res) {
  console.log('getPupilsTaskStates body', req.body);

	let pupilsId = req.body.pupilsId;
	let taskId = req.body.taskId;
	
    if (!taskId) {
		console.error('err. No required parameters');
		res.send('err. No required parameters');
		return;
	}


	let filter = {};	
	filter.taskId = taskId;
	
	console.log('got pupilsId', pupilsId);
	if (pupilsId) {
		filter.pupilId = { $in: JSON.parse(pupilsId) }
	}
	
	console.log('got filter', filter);
	
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		col = client.db("homeTasks").collection("pupilSolvedTasks");
		
		col.find( filter ).toArray((err, ar)=>{
			if (err) {
				console.log('some err on get getPupilsTaskStates ', err);			
				res.send(err);
			} else {
				console.log('got getPupilsTaskStates ', ar.length);
				console.log('got getPupilsTaskStates ', ar);
				
				let arTaskStatus = [];
				ar.forEach(el=>{
					stateEl = {};
					stateEl.pupilId = el.pupilId;
					stateEl.status = '';
					if (el.mark) {
						stateEl.status = el.mark;
					} else if (el.isSolved) {
						stateEl.status = '-';
					}
					arTaskStatus.push(stateEl);
				});
				res.send(JSON.stringify({err, ar: arTaskStatus}));
			}
		});
	});
	
})


//********************** city ************************ 

app.post('/getCities', function (req, res) {
  console.log('getCities body', req.body);
	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		let col = client.db("homeTasks").collection("cities");

		col.find( {} ).toArray((err, ar)=>{
			if (err) {
				console.log('some err on got cities', err);			
				res.send(err);
			} else {
				console.log('got cities ', ar.length);			
				res.send(JSON.stringify({err, ar}));
			}
		});
	});
})


app.post('/add_city', function (req, res) {
	console.log('add_city body',req.body);

	if (!req.body.city) {
		console.log('err add_city( No cityName!');
		res.send('err. no city to add');
		return;
	}

	client.connect(err => {
		console.log('mongo client connect');
		if (err) {
			console.error('some err on connect to mongo', err);
			res.send(err);
			return;
		}
		homeTasksCol = client.db("homeTasks").collection("cities");

		homeTasksCol.insertOne(req.body, (err, newRecord)=>{
			if (err) {
				console.log('err on ins new city(', err) 
				res.send(err);
			} else {
				console.log('ok on ins newCity, got id', newRecord.insertedId);
				res.send("OK " + newRecord.insertedId);
			}
		});
	});

});

//---------------------------------------------

function conv2Eng(rus){
	let reObj = {
		"а":"a",
		"б":"b",
		"в":"v",
		"г":"g",
		"д":"d",
		"е":"e",
		"ё":"yo",
		"ж":"zh",
		"з":"z",
		"и":"i",
		"й":"j",
		"к":"k",
		"л":"l",
		"м":"m",
		"н":"n",
		"о":"o",
		"п":"p",
		"р":"r",
		"с":"s",
		"т":"t",
		"у":"u",
		"ф":"f",
		"х":"h",
		"ц":"c",
		"ч":"ch",
		"ш":"sh",
		"щ":"sch",
		"ъ":"",
		"ь":"",
		"ы":"y",
		"э":"e",
		"ю":"yu",
		"я":"ya",
		".":"-",
		"/":"-"
	};
	rus = rus.toLowerCase();
	res = "";
	for (let i=0; i<rus.length; i++){
		newLetter = reObj[rus[i]];
		if (newLetter == undefined) newLetter = rus[i];
		res += newLetter;
	}
	return res;
}
