class ProjectModel {
  final String projectName;
  ProjectModel({required this.projectName});
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(projectName: json['project_name']);
  }
  Map<String, dynamic> toJson() {
    return {'project_name': projectName};
  }
}
