pragma solidity ^0.8.0;

contract MedicalRecords {

    // Структура пациента
    struct Patient {
        string name;
        uint256 birthdate;
        string[] records;
    }
    // Сопоставление адресов пациентов с их информацией
    mapping(address => Patient) private patients;
    // Сопоставление адресов врачей с их статусом авторизации
    mapping(address => bool) private doctors;

    // Модификатор для ограничения доступа к функциям только для врачей
    modifier  OnlyDoctorOrOwner() {
        require(doctors[msg.sender] || msg.sender == tx.origin, "Only doctors can perform this action.");
        _;
    }

    // Добавить нового врача
    function addDoctor(address doctorAddress) public OnlyDoctorOrOwner {
        doctors[doctorAddress] = true;
    }

    // Удалить существующего врача
    function removeDoctor(address doctorAddress) public OnlyDoctorOrOwner {
        doctors[doctorAddress] = false;
    }

    // Зарегистрировать нового пациента с его именем и датой рождения
    function registerPatient(string memory name, uint256 birthdate) public {
        patients[msg.sender] = Patient(name, birthdate, new string[](0));
    }

    // Обновить имя пациента
    function updatePatientName(address patientAddress, string memory newName) public OnlyDoctorOrOwner {
        require(bytes(patients[patientAddress].name).length != 0, "Patient not registered.");
        patients[patientAddress].name = newName;
    }

    // Обновить дату рождения пациента
    function updatePatientBirthdate(address patientAddress, uint256 newBirthdate) public OnlyDoctorOrOwner {
        require(bytes(patients[patientAddress].name).length != 0, "Patient not registered.");
        patients[patientAddress].birthdate = newBirthdate;
    }

    // Добавить новую медицинскую запись для пациента
    function addRecord(address patientAddress, string memory record) public OnlyDoctorOrOwner {
        require(bytes(patients[patientAddress].name).length != 0, "Patient not registered.");
        patients[patientAddress].records.push(record);
    }

    // Удалить медицинскую запись для пациента
    function removeRecord(address patientAddress, uint256 recordIndex) public OnlyDoctorOrOwner {
        require(bytes(patients[patientAddress].name).length != 0, "Patient not registered.");
        require(recordIndex < patients[patientAddress].records.length, "Invalid record index.");
        patients[patientAddress].records[recordIndex] = patients[patientAddress].records[patients[patientAddress].records.length - 1];
        patients[patientAddress].records.pop();
    }

    // Просмотр медицинских записей пациента (доступно врачам)
    function viewRecords(address patientAddress) public view OnlyDoctorOrOwner returns (string[] memory) {
        require(bytes(patients[patientAddress].name).length != 0, "Patient not registered.");
        return patients[patientAddress].records;
    }

    // Просмотр собственных медицинских записей (доступно пациентам)
    function viewOwnRecords() public view returns (string[] memory) {
        require(bytes(patients[msg.sender].name).length != 0, "Patient not registered.");
        return patients[msg.sender].records;
    }
}