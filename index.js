const { request } = require('express');
var express = require('express');
cors = require('cors');
app = express();
bodyParser= require('body-parser');

var distDir = __dirname;
app.use(express.static(distDir));

const port= process.env.PORT || 3030;

//załadowanie routerów
dodajprzelew= require('./routes/newprzelew');
api1= require('./routes/api');

app.use(cors());

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(bodyParser.raw());

//dodanie routerów do serwera
app.use(dodajprzelew);
app.use(api1);











app.listen(port, () => console.log(`Serwer uruchomiony. Nasluchuje na porcie ${port}`));