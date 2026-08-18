function gyro = getGyro(gyro)
% Return gyromagnetic constant for nuclei below in Hz/T.

switch gyro
    case '1H',      gyro = 42.57747892*1e6;
    case '2H',      gyro = 6.536      *1e6;
    case '31P',     gyro = 17.235     *1e6;
    case '23Na',    gyro = 11.262     *1e6;
    case '19F',     gyro = 40.052     *1e6;
end