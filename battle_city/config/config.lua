return{
  login = {
    db = {
      address = "127.0.0.1",
      db_name = "battle_city",
    },

    gate_list = {
      {
        address = "0.0.0.0",
        port = 10000,
        maxclient = 2048,
      }
    }
  },

  master = {
    db = {
      address = "127.0.0.1",
      db_name = "battle_city",
    },

    gate_list = {
      {
        address = "0.0.0.0",
        port = "10001",
        maxclient = 2048,
      },
      {
        address = "0.0.0.0",
        port = "10002",
        maxclient = 2048,
      }
    }
  },

  battle = {
    gate_list = {
      {
        address = "0.0.0.0",
        port = "10003",
        maxclient = 2048,
      },
      {
        address = "0.0.0.0",
        port = "10004",
        maxclient = 2048,
      }
    }
  },



}
