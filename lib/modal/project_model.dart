class ProjectModel {
  int? id;
  String? projectName;

  ProjectModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    projectName = json['project_name'];
  }
}