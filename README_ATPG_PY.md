# ATPG execution — command flow (using atpg.py)

```sh
# (optional) make the script executable
chmod +x atpg.py

# Run the ATPG runner (choose one)
./atpg.py
# or
python3 atpg.py

# The script internally performs these steps (placeholders shown):
rm -rf xcelium.d cov_work xrun.log xrun.history waves.shm dump.vcd
xrun -uvm -64bit -svseed <seed> -access +rwc -top <TOP> -l xrun.log -coverage all -covoverwrite -covtest test_sv<seed> <SOURCE_FILES> -gui
imc -load cov_work/scope/test_sv<seed>
```
