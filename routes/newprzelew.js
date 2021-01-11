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

// GET przelewy dla banku
router.get("/przelewy", (req,res) => {

    if (req.query.nr_banku) {
        //console.log(req.query.nr_banku)
        if (bank_decode(req.query.nr_banku)) {

            let bank=req.query.nr_banku.substr(2,24);
            let sqlselect= `SELECT * from transakcje where bank_odbiorcy=${bank} AND status=1`;
            //console.log(sqlselect);

            request(sqlselect).then(transakcje => {

                updatestatus(transakcje);

                for (t of transakcje)
                    delete t.id_transakcji;
                res.send(transakcje);

                

            })
            .catch(err => {
                console.error("Cos nie tak z pobraniem transakcji");
                res.status(500);
                res.send("Error");
                throw Error(err);
            })

        }
        else{
            res.status(400);
            res.send("Niepoprawny nr banku")
        }

    }
    else{
        res.status(500);
        res.send("Brak wymaganego parametru");
    }

    function updatestatus(transactions) {
        let t_array= [];
        for (t of transactions){
            let sqlstatus = `UPDATE transakcje set status=2 where id_transakcji=${t.id_transakcji}`;
            t_array.push(request(sqlstatus));
        }

        let odejmijsaldo=transactions.map(x => {return x.kwota});

        if (odejmijsaldo.length>0){
            
            odejmijsaldo=odejmijsaldo.reduce((prev,now) => {return prev+now});
            let saldosql=`UPDATE rachunki set saldo=saldo-${odejmijsaldo} where nr_rachunku=`+transactions[0].bank_odbiorcy;

            request(saldosql)
            .catch(err => {
                console.log("nie udalo sie zaktualizowqac salda")
                throw Error(err);
            })
        }
            

        //console.log(saldosql);
        

        Promise.all(t_array).then(() => {
            console.log("Zaktualizowano status transakcji")
        })
        .catch(err => {
            console.error("Problem z zaktualizowaniem statusu transakcji");
            throw Error(err);
        })
        //console.dir(t_array);
    }

})


// POST nowy przelew
router.post("/przelewy",(req,res) => {

    var dane=req.body;
    console.dir(dane);

    //console.log(bank_decode(dane.rachunek_nadawcy));

    if (bank_decode(dane.rachunek_nadawcy) && bank_decode(dane.rachunek_odbiorcy)){

        var rach_nadawcy= dane.rachunek_nadawcy.substr(2,8);
        var rach_odbiorcy= dane.rachunek_odbiorcy.substr(2,8);
        var rach_dopelnienie= '0000000000000000';

        let sql_rach_nadawcy = `select * from rachunki where nr_rachunku = '${rach_nadawcy}${rach_dopelnienie}'`;
        let sql_rach_odbiorcy = `select * from rachunki where nr_rachunku = '${rach_odbiorcy}${rach_dopelnienie}'`; 

        //console.log(sql_rach_nadawcy+"\n"+sql_rach_odbiorcy);

        // --------------------- Sprawdzanie Nadawcy
        request(sql_rach_nadawcy).then((nadawcy) => {
             if (nadawcy.length>0){
                 console.log("Nadawca istnieje");
                 console.log("");
                 //tu wywolac funkcje kolejna
                sprawdz_odbiorce();

             }
             else{
                 console.log("Nadawca nie istnieje");
                 //zakladamy mu konto
                 let stworzbank= 'INSERT INTO `banki` (`nazwa`,`adres`,`kontakt`) VALUES ("N/A","N/A","N/A")';
                 //console.log(stworzbank);

                 request(stworzbank).then(nowybank => {

                    let saldostartowe=0;
                    let stworzrachunek = 'INSERT INTO `rachunki` (`id_banku`,`nr_rachunku`,`saldo`) VALUES'+` (${nowybank.insertId},${rach_nadawcy}${rach_dopelnienie},${saldostartowe})`;
                    //console.log(stworzrachunek);
                    
                    request(stworzrachunek).then(nowyrachunek => {

                        console.dir(nowyrachunek);
                        console.log("Teraz sprawdzic odbiorce")
                        sprawdz_odbiorce();
                    })

                 })
                 .catch(err => {
                     console.error("cos nie tak z zalozeniem banku");
                     throw Error(err);
                 })
             }

        })
        .catch(err => {
            console.error("Cos nie tak z pobraniem rachunku");
            throw Error(err);
        })

        //   --------------------sprawdzenie odbiorcy
        function sprawdz_odbiorce(){

            request(sql_rach_odbiorcy).then(odbiorca => {

                if (odbiorca.length>0){
                    console.log("Odbiorca instnieje");
                    // wywolanie kolejnego etapu
                    utworz_transakcje();
                }
                else{
                    console.log("Odbiorca nie istnieje");
                    res.status(500);
                    res.send("Rachunek odbiorcy nie jest zarejstrowany w jednostce rozliczjacej");
                }


            })
            .catch(err => {
                console.log("Cos nie tak z pobraniem odbiorcy");
                throw Error(err);
            })
            
        }

        function utworz_transakcje(){

            let date=new Date();
            let timestamp= (''+date.getTime()).substr(9,4);
            generatenr= (('0' + date.getDate()).slice(-2) + '' + ('0' + (date.getMonth()+1)).slice(-2) + + ('0' + date.getYear()).slice(-2) + '' + timestamp);
            console.log(generatenr);

            let sql_newtransakcja = "INSERT INTO `transakcje`(`numer_transakcji`, `typ_operacji`, `data`, `status`, `bank_nadawcy`, `bank_odbiorcy`,`rachunek_nadawcy`, `nazwa_nadawcy`, `adres_nadawcy`, `rachunek_odbiorcy`, `nazwa_odbiorcy`, `adres_odbiorcy`, `kwota`, `tytul`) VALUES ";
            sql_newtransakcja+=`('${generatenr}',1,'${dane.data}',1,'${rach_nadawcy}${rach_dopelnienie}','${rach_odbiorcy}${rach_dopelnienie}','${dane.rachunek_nadawcy}','${dane.nazwa_nadawcy}','${dane.adres_nadawcy}','${dane.rachunek_odbiorcy}','${dane.nazwa_odbiorcy}','${dane.adres_odbiorcy}',${dane.kwota},'${dane.tytul}')`;

            //console.log(sql_newtransakcja);

            request(sql_newtransakcja).then(transakcja => {
                console.log("Wszystko w porzasiu");


                //zwroc numer transakcji
                res.status(200);
                res.send(generatenr);

            })
            .catch(err => {
                res.status(500);
                res.send("Error");
                console.error("Cos nie tak z dodanie transakcji");
                throw Error(err);
            })

        }

    }
    else{
        console.log("Niepoprawny nr ktoregos banku");
        res.status(400);
        res.send("Niepoprawny nr ktoregos z bankow");
    }
    
})



function bank_decode(nr){

    if (nr.length==26){
        let nr_banku = nr.substr(2,8);
        //console.log(nr_banku);
        nr_banku= nr_banku.split('');

        let wagi = [3,9,7,1,3,9,7];

        //console.log(nr_banku);

        let suma=0;
        for (let i in wagi) {
            let nrtemp= +nr_banku[i];
            suma+=wagi[i]*nrtemp;
        }

        suma=suma%10;

        if (suma==0){
            return true;
        }
        else{
            suma= 10-suma;
            //console.log("l.kontrolna: "+suma);
            if (suma == nr_banku[7]){
                return true;
            }
            else{
                return false;
            }
        }

        //console.log(suma);
    }
    else {
        return false;
    }
    
}


module.exports = router