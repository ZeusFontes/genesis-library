import '../models/profile.dart';

class ProfilesMock {
  // Lista de cores: Vermelho, Roxo, Amarelo, Azul e Verde
  static const String _colorPool = 'E50914,9D4EDD,ECA823,0A74DA,10B981';

  static final List<Profile> profiles = [
    Profile(
      id: 'p1',
      name: 'Admin',
      avatar:
          'https://api.dicebear.com/10.x/thumbs/png?seed=Admin&backgroundColor=$_colorPool&shapeColor=$_colorPool',
    ),
    Profile(
      id: 'p2',
      name: 'Zeus',
      avatar:
          'https://api.dicebear.com/10.x/thumbs/png?seed=Zeus&backgroundColor=$_colorPool&shapeColor=$_colorPool',
    ),
    Profile(
      id: 'p3',
      name: 'Amaral',
      avatar:
          'https://api.dicebear.com/10.x/thumbs/png?seed=Amaral&backgroundColor=$_colorPool&shapeColor=$_colorPool',
    ),
  ];
}
