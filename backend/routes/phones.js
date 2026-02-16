const express = require('express')
const sql = require('mssql')
const config=require('../dbconfig')
const router = express.Router()

router.get('/',async (req,res)=>{
    try{
    const pool = await sql.connect(config)
    const result = await pool.request().query(
        `
        SELECT
        id,
        Marka,
        Kiadas,
        Tipus,
        Ar
        FROM Telefonok 
        ORDER BY id
        `
    )
    pool.close()
    res.json({success:true, data: result.recordset})
    }
    catch(error){
        res.status(500).json({success: false, error: error.message})
    }

})

router.post('/', async(req,res) =>{
    try{
        const {nev, kaloria, ar} = req.body
        const pool = await sql.connect(config)

        await pool.request()
            .input('nev', sql.NVarChar, nev)
            .input('kaloria', sql.Int, kaloria)
            .input('ar', sql.Int, ar)
            .query(`
                INSERT INTO Sutemenyek (nev, kaloria, ar)
                VALUES(@nev, @kaloria, @ar)
                `)
                pool.close()
                res.status(201).json({success:true})
    }
    catch(error){
        res.status(500).json({success:false, error: error.message})
    }
})

//PUT api/cakes/:id

router.put('/:id', async (req,res) =>{
    try{
        const {id} = req.params
        const {nev, kaloria, ar} = req.body

        const pool = await sql.connect(config)
        const result = pool.request()
        .input('id', sql.Int, id)
        .input('nev', sql.NVarChar, nev)
        .input('kaloria', sql.Int, kaloria)
        .input('ar', sql.Int, ar)
        .query(`
            UPDATE Sutemenyek
            SET
            nev = @nev,
            kaloria = @kaloria,
            ar = @ar
            WHERE id = @id`)
            pool.close()
            res.json({success:true})
    }   
    catch(err){
        res.status(500).json({
            success: false,
            error: err.message
        })
        
    }
})

//DELETE api/cakes/:id

router.delete('/:id', async (req,res) =>{
    try{
        const {id} = req.params

        const pool = await sql.connect(config)
        await pool.request()
        .input('id', sql.Int, id)
        .query(`
            DELETE FROM Sutemenyek
            WHERE id = @id`)
            pool.close()
            res.json({success:true})
    }   
    catch(err){
        res.status(500).json({
            success: false,
            error: err.message
        })
        
    }
})

module.exports = router