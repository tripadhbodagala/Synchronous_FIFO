//SEQUENCE
class sequencee extends uvm_sequence #(fifo_txn);
  `uvm_object_utils(sequencee)

  function new(string name = "sequencee");
    super.new(name);
  endfunction

  task body();
    // fill, including 2 writes at full (overflow attempts)
    repeat (18) begin
      req = fifo_txn::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {rst==0; we==1; re==0;});
      finish_item(req);
    end

    // drain, including 2 reads at empty (underflow attempts)
    repeat (18) begin
      req = fifo_txn::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {rst==0; we==0; re==1;});
      finish_item(req);
    end

    // mixed random traffic
    repeat (200) begin
      req = fifo_txn::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {rst==0;
                                   we dist {1:=6, 0:=4};
                                   re dist {1:=4, 0:=6};});
      finish_item(req);
    end

    // reset in the middle of traffic
    req = fifo_txn::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {rst==1; we==0; re==0;});
    finish_item(req);

    // a few idle cycles after reset
    repeat (4) begin
      req = fifo_txn::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {rst==0; we==0; re==0;});
      finish_item(req);
    end
  endtask

  task send(bit r, bit w, bit rd);
  req = fifo_txn::type_id::create("req");
  start_item(req);
  if (!req.randomize() with {rst == r; we == w; re == rd;})
    `uvm_fatal("SEQ", "randomization failed")
  finish_item(req);
endtask
endclass