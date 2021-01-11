const { query } = require('express');
const express= require('express');
const router = express.Router();

db = require('../db');

async function request(sql){
    return new Promise((resolve,reject) => {
        db.query(sql,(err,res) => {
            if (err)
                reject(err);
            resolve(res);
        })
    })
}

router.get("/api/getrachunki",(req,res) => {
    let sql = `Select * from rachunki`
    request(sql).then(r => {
        res.send(r);
    })
})

router.get("/api/bank", (req,res) => {
    if (req.query.nr){
        let sql ="Select * from banki where id_banku="+req.query.nr;

        request(sql).then(r => {
            if (r.length>0){
                res.send(r[0]);
            }
            else {
                res.send({});
            }
            
        })
    }
    else {
        res.send("nope")
    }
})

router.get("/api/transakcje",(req,res)=>{
    if (req.query.nr){
        let sql ="Select * from transakcje where bank_nadawcy="+req.query.nr+" OR bank_odbiorcy="+req.query.nr+" order by data desc";

        request(sql).then(r => {
            if (r.length>0){
                res.send(r);
            }
            else{
                res.send([]);
            }
        })
    }
})

router.put("/api/bank",(req,res) => {
    console.dir(req.body);
    let dane = req.body.data;
    if (dane.id_banku){
        let sql= `UPDATE banki set nazwa='${dane.nazwa}',adres='${dane.adres}',kontakt='${dane.kontakt}' where id_banku=${dane.id_banku}`
        
        request(sql).then(r => {
            res.send({"success":"ok"});
        })
    }
    else{
        res.send({"error":"wrong parameters"})
    }
})

















module.exports = router