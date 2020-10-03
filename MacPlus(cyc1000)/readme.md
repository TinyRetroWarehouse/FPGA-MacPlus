# Macintosh Plus for the [MiSTer Board](https://github.com/MiSTer-devel/Main_MiSTer/wiki)
This is a port of the [Plus Too core](https://github.com/mist-devel/mist-binaries/tree/master/cores/plus_too) from MiST which is the port of the [Plus Too project](http://www.bigmessowires.com/plus-too/).
I've tried to optimize the code with converting to synchronous style and fixing some glitches and instabilities.

��Macintosh Plus for [MiSTer Board]�ihttps://github.com/MiSTer-devel/Main_MiSTer/wiki�j
����́A[Plus Too�v���W�F�N�g]�̃|�[�g�ł���MiST�����[Plus Too�R�A]�ihttps://github.com/mist-devel/mist-binaries/tree/master/cores/plus_too�j�̃|�[�g�ł��i http://www.bigmessowires.com/plus-too/�j�B
�����X�^�C���ɕϊ����A�������̕s���s���萫���C�����āA�R�[�h���œK�����悤�Ƃ��܂����B

## Usage

* Copy the [*.rbf](https://github.com/MiSTer-devel/MacPlus_MiSTer/tree/master/releases) onto the root of SD card
* Copy the [boot.rom](https://github.com/MiSTer-devel/MacPlus_MiSTer/tree/master/releases) to MacPlus folder
* Copy disk images in dsk format (e.g. Disk605.dsk) to MacPlus folder

After a few seconds the floppy disk icon should
appear. Open the on screen display using the F12 key and select the
a disk image. The upload of the disk image will take a few seconds. MacPlus will then boot into the MacOS desktop.

���� �g�p�@

* [* .rbf]�ihttps://github.com/MiSTer-devel/MacPlus_MiSTer/tree/master/releases�j��SD�J�[�h�̃��[�g�ɃR�s�[���܂�
* [boot.rom]�ihttps://github.com/MiSTer-devel/MacPlus_MiSTer/tree/master/releases�j��MacPlus�t�H���_�ɃR�s�[���܂�
*�f�B�X�N�C���[�W��dsk�`���iDisk605.dsk�Ȃǁj��MacPlus�t�H���_�[�ɃR�s�[����

���b��A�t���b�s�[�f�B�X�N�̃A�C�R�����\������܂��B
�����B F12�L�[���g�p���ăI���X�N���[���f�B�X�v���C���J���A
�f�B�X�N�C���[�W�B �f�B�X�N�C���[�W�̃A�b�v���[�h�ɂ͐��b������܂��B MacPlus��MacOS�f�X�N�g�b�v�ŋN�����܂��B

## Floppy disk image format
Floppy disk images need to be in raw disk format. Double sided 800k disk images have to be exactly 819200 bytes in size. Single sided 400k disk images have to be exactly 409600 bytes in size.
Both the internal as well as the external floppy disk are supported. The first entry in the OSD refers to the internal floppy disk, the second one to the external floppy disk.
Currently floppy disk images cannot be loaded while the Mac accesses a floppy disk. Thus it's recommended to wait for the desktop to appear until a second floppy can be inserted.
Before loading a different disk image it's recommended to eject the previously inserted disk image from within MacOS.
Official system disk images are available from apple at [here](https://web.archive.org/web/20141025043714/http://www.info.apple.com/support/oldersoftwarelist.html). Under Linux these can be converted into the desired dsk format using [Linux stuffit](http://web.archive.org/web/20060205025441/http://www.stuffit.com/downloads/files/stuffit520.611linux-i386.tar.gz), unar and [dc2dsk](http://www.bigmessowires.com/dc2dsk.c) in that order. A shell script has been provided for convenience at [releases/bin2dsk.sh](releases/bin2dsk.sh).

##�t���b�s�[�f�B�X�N�C���[�W�`��
�t���b�s�[�f�B�X�N�C���[�W��raw�f�B�X�N�`���ł���K�v������܂��B����800k�f�B�X�N�C���[�W�́A���m��819200�o�C�g�̃T�C�Y�łȂ���΂Ȃ�܂���B�Ж�400k�f�B�X�N�C���[�W�̃T�C�Y�́A���m��409600�o�C�g�łȂ���΂Ȃ�܂���B
�����t���b�s�[�f�B�X�N�ƊO�t���t���b�s�[�f�B�X�N�̗������T�|�[�g����Ă��܂��B OSD�̍ŏ��̃G���g���͓����t���b�s�[�f�B�X�N���Q�Ƃ��A2�Ԗڂ̃G���g���͊O���t���b�s�[�f�B�X�N���Q�Ƃ��܂��B
���݁AMac���t���b�s�[�f�B�X�N�ɃA�N�Z�X���Ă���Ԃ́A�t���b�s�[�f�B�X�N�C���[�W�����[�h�ł��܂���B���������āA2���ڂ̃t���b�s�[��}���ł���悤�ɂȂ�܂Ńf�X�N�g�b�v���\�������̂�҂��Ƃ������߂��܂��B
�ʂ̃f�B�X�N�C���[�W�����[�h����O�ɁA�ȑO�ɑ}�������f�B�X�N�C���[�W��MacOS��������o�����Ƃ������߂��܂��B
�����̃V�X�e���f�B�X�N�C���[�W�́A�A�b�v����[������]�ihttps://web.archive.org/web/20141025043714/http://www.info.apple.com/support/oldersoftwarelist.html�j�������ł��܂��B Linux�ł́A[Linux stuffit]�ihttp://web.archive.org/web/20060205025441/http://www.stuffit.com/downloads/files/stuffit520.611linux-i386�j���g�p���āA������ړI��dsk�`���ɕϊ��ł��܂��B .tar.gz�j�Aunar�A[dc2dsk]�ihttp://www.bigmessowires.com/dc2dsk.c�j�̏��ԂŁB [releases / bin2dsk.sh]�ireleases / bin2dsk.sh�j�ɂ́A�֗��ȃV�F���X�N���v�g���p�ӂ���Ă��܂��B

## Hard disk support
This MacPlus core implements the SCSI interface of the Macintosh Plus together with a 20MB harddisk. The core implements only a subset of the SCSI commands. This is currently sufficient to read and write the disk, to boot from it and to format it using the setup tools that come with MacOS 6.0.8.
The harddisk image to be used can be selected from the "Mount *.vhd" entry in the on-screen-display. Copy the boot.vhd to MacPlus folder and it will be automatically mounted at start. The format of the disk image is the same as being used by the SCSI2SD project which is documented [here](http://www.codesrc.com/mediawiki/index.php?title=HFSFromScratch).
Unlike the floppy the SCSI disk is writable and data can be written to the disk from within the core.
It has been tested that OS 6.0.8 can format the SCSI disk as well as doing a full installation from floppy disk to the harddisk. But keep in mind that this is an early work in progress and expect data loss when working with HDD images.
A matching harddisk image file can be found [here](https://github.com/MiSTer-devel/MacPlus_MiSTer/tree/master/releases). This is a 20MB harddisk image with correct partitioning information and a basic SCSI driver installed. The data partition itself is empty and unformatted. After booting the Mac will thus ask whether the disk is to be initialized. Saying yes and giving the disk a name will result im a usable file system. You don't need to use the Setup tool to format this disk as it is already formatted. But you can format it if you want to. This is only been tested with OS 6.0.8.

##�n�[�h�f�B�X�N�̃T�|�[�g
����MacPlus�R�A�́AMacintosh Plus��SCSI�C���^�[�t�F�C�X��20MB�̃n�[�h�f�B�X�N���������Ă��܂��B�R�A��SCSI�R�}���h�̃T�u�Z�b�g�݂̂��������܂��B����͌��݁A�f�B�X�N�̓ǂݎ��Ə������݁A�f�B�X�N����̋N���AMacOS 6.0.8�ɕt���̃Z�b�g�A�b�v�c�[�����g�p�����t�H�[�}�b�g�ɏ\���ł��B
�g�p����n�[�h�f�B�X�N�C���[�W�́A�I���X�N���[���f�B�X�v���C�́uMount * .vhd�v�G���g������I���ł��܂��B boot.vhd��MacPlus�t�H���_�ɃR�s�[����ƁA�N�����Ɏ����I�Ƀ}�E���g����܂��B�f�B�X�N�C���[�W�̃t�H�[�}�b�g�́A[����]�ihttp://www.codesrc.com/mediawiki/index.php?title=HFSFromScratch�j�ɋL�ڂ���Ă���SCSI2SD�v���W�F�N�g�Ŏg�p����Ă�����̂Ɠ����ł��B
�t���b�s�[�Ƃ͈قȂ�ASCSI�f�B�X�N�͏������݉\�ŁA�R�A������f�B�X�N�Ƀf�[�^���������ނ��Ƃ��ł��܂��B
OS 6.0.8��SCSI�f�B�X�N���t�H�[�}�b�g���A�t���b�s�[�f�B�X�N����n�[�h�f�B�X�N�Ɋ��S�ɃC���X�g�[���ł��邱�Ƃ��e�X�g����Ă��܂��B�������A����͏����i�K�̍�Ƃł���AHDD�C���[�W���g�p����ꍇ�̓f�[�^�̑������\�z����邱�Ƃɒ��ӂ��Ă��������B
��v����n�[�h�f�B�X�N�C���[�W�t�@�C����[������]�ihttps://github.com/MiSTer-devel/MacPlus_MiSTer/tree/master/releases�j�ɂ���܂��B����́A�������p�[�e�B�V�������Ɗ�{�I��SCSI�h���C�o���C���X�g�[�����ꂽ20MB�̃n�[�h�f�B�X�N�C���[�W�ł��B�f�[�^�p�[�e�B�V�������̂͋�ŁA�t�H�[�}�b�g����Ă��܂���B���������āAMac�̋N����A�f�B�X�N�����������邩�ǂ�����q�˂��܂��B�͂��ƌ����ăf�B�X�N�ɖ��O��t����ƁA�g�p�\�ȃt�@�C���V�X�e���ɂȂ�܂��B���̃f�B�X�N�͊��Ƀt�H�[�}�b�g����Ă��邽�߁A�Z�b�g�A�b�v�c�[�����g�p���ăt�H�[�}�b�g����K�v�͂���܂���B�������A�K�v�ɉ����ăt�H�[�}�b�g�ł��܂��B�����OS 6.0.8�ł̂݃e�X�g����Ă��܂��B

## CPU Speed
The CPU speed can be adjusted from "normal" which is roughly Mac Plus speed to "Fast" which is about 2.5 times faster. Original core couldn't boot from SCSI in turbo mode. This port has workaround to let it boot even with turbo mode.
## CPU���x
CPU���x�́A�����悻Mac Plus���x�ł���u�ʏ�v�����2.5�{�����u�����v�܂Œ����ł��܂��B ���̃R�A�̓^�[�{���[�h��SCSI����N���ł��܂���ł����B ���̃|�[�g�ɂ́A�^�[�{���[�h�ł��N���ł������􂪂���܂��B

## Memory
512KB, 1MB and 4MB memory configs are available. Cold boot with 4MB RAM selected takes some time before it start to boot from FDD/SCSI, so be patient. Warm boot won't take long time.
##������
512KB�A1MB�����4MB�̃������\�������p�\�ł��B 4MB RAM��I��������Ԃł̃R�[���h�u�[�g�́AFDD / SCSI����u�[�g���J�n����܂łɎ��Ԃ������邽�߁A���΂炭���҂����������B �E�H�[���u�[�g�ɂ͎��Ԃ�������܂���B

## Keyboard
The Alt key is mapped to the Mac's command key, and the Windows key is mapped to the Mac's option key. Core emulates keyboard with keypad.
##�L�[�{�[�h
Alt�L�[��Mac�̃R�}���h�L�[�Ƀ}�b�v����AWindows�L�[��Mac�̃I�v�V�����L�[�Ƀ}�b�v����܂��B �R�A�̓L�[�p�b�h�ŃL�[�{�[�h���G�~�����[�g���܂��B