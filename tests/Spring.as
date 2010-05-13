// forked from siouxcitizen's Spring03:　夜桜イメージをGlowFilterを使用して表現してみました
//季節はずれですが。。。
//DAE形式の3D「のまねこ」を読み込んで操作対象3Dオブジェクトとしてみました
//「前進」「Bダッシュ」「後退」「左回転」「右回転」ボタンで3D「のまねこ」を操作できます
//
//ランド画面でPlaneオブジェクトでできた緑色の床をクリックすると以下のように変化します
//緑色→土色→土色＋桜→緑色と遷移します
//「リセット」ボタンで床を初期化(全ての床を緑色の床に戻します)
//「桜散」ボタンで桜の花にみたてたパーティクルが散り(落ち)ます
//「夜桜」ボタンでGlowFilterの効果で桜と月が光ります
//
//ランド画面でのカメラ視点移動
//Wボタンでカメラ視点上移動
//Sボタンでカメラ視点下移動
//Aボタンでカメラ視点が操作用3D「のまねこ」を中心に左周り
//Dボタンでカメラ視点が操作用3D「のまねこ」を中心に右周り
//Fボタンでカメラ距離変更
//Rボタンでカメラの初期化(カメラの距離と高さを初期状態に設定＆カメラ視点を操作用3D「のまねこ」の真後ろに設定)
//タイトル画面に一度戻ってからランド画面再表示で操作用3D「のまねこ」とカメラ視点を初期化
//タイトル画面に戻っても背景の設定は残るようになってます
package {
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.filters.GlowFilter;

    import org.papervision3d.view.Viewport3D;
    import org.papervision3d.scenes.Scene3D;
    import org.papervision3d.objects.primitives.Plane;
    import org.papervision3d.objects.primitives.Cube;
    import org.papervision3d.objects.primitives.Cylinder;
    import org.papervision3d.objects.primitives.Cone;
    import org.papervision3d.objects.primitives.Sphere;
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.materials.WireframeMaterial;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.materials.ColorMaterial;
    import org.papervision3d.render.BasicRenderEngine;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.events.InteractiveScene3DEvent;

    import org.papervision3d.materials.special.Letter3DMaterial;
    import org.papervision3d.typography.Text3D;
    import org.papervision3d.typography.fonts.HelveticaBold;

    import org.papervision3d.materials.special.ParticleMaterial;
    import org.papervision3d.objects.special.ParticleField;
    import org.papervision3d.core.geom.renderables.Particle;

    import org.papervision3d.objects.parsers.DAE;

    [SWF(width="500", height="500", backgroundColor="#0055FF")]
    public class Spring extends Sprite {
        private var goLandScrnBtn : SimpleButton;//ランド画面への遷移ボタン 
        private var resetBtn : SimpleButton;//リセットボタン
        private var sakuraFallBtn : SimpleButton;//「桜散」ボタン
        private var sakuraFallState : Boolean = false; //「桜散」ボタン状態管理用
        private var sakuraNightBtn : SimpleButton;//「夜桜」ボタン
        private var sakuraNightState : Boolean = false; //「夜桜」ボタン状態管理用
        private var goTitleScrnBtn : SimpleButton;//タイトル画面への遷移ボタン
        private var forwardBtn : SimpleButton;//前進ボタン
        private var leftRotBtn : SimpleButton;//左回転ボタン
        private var rightRotBtn : SimpleButton;//右回転ボタン
        private var backwardBtn : SimpleButton;//後退ボタン
        private var bDashBtn : SimpleButton;//Bダッシュボタン
        private var forwardState : Boolean = false; //操作矢印「前進」制御用
        private var backwardState : Boolean = false; //操作矢印「後退」制御用
        private var bDashState : Boolean = false; //操作矢印「Bダッシュ」制御用
        private var leftRotState : Boolean = false; //操作矢印「左回転」制御用
        private var rightRotState : Boolean = false; //操作矢印「右回転」制御用

        private var txtField:Object=new Object(); //テキストフィールド用
        private var txtFormat:Object=new Object();//テキストフォーマット用

        private var screenId : int = 0;  //0:クエスト画面 1:ランド画面
        private const TITLE_SCREEN_ID : int = 0;  //クエスト画面ID
        private const LAND_SCREEN_ID : int = 1;  //ランド画面ID

        //3D表示用
        private var container : Sprite;
        private var viewport : Viewport3D;
        private var scene : Scene3D;
        private var camera : Camera3D;
        private var material : ColorMaterial;
        private var planeObj : Plane; 
        private var daeNomaneko : DAE //操作用3D「のまねこ」DAE
        private var crystalBoxCube : Cube //透明キューブ　飾り用クリスタル役
        private var moonSphere : Sphere //月スフェア
        private var renderer : BasicRenderEngine;
        private var materialList : MaterialsList = new MaterialsList();

        private var cameraPitch: int = 90; //カメラのX軸回転の値　
        private var cameraYaw : int = 270; //カメラのY軸回転の値　
        private var cameraDistStat: int = 1; //カメラ設置場所の距離種類　0～2

        private var title3DText : Text3D //タイトル3D文字
        private var letterformat : Letter3DMaterial; //タイトル3D文字フォーマット
        private var tempPlaneName : String;
        private var Objs : Object = new Object(); //3Dオブジェクト保持用

        private var particleMat : ParticleMaterial; //生成するパーティクルのマテリアル
        private var particleField : ParticleField; //生成するパーティクルのマテリアル
        private var pFieldHeight : int;
        private var numParticles : int;
        private var fieldSize : int;
        private var theta : Number = 0;
        private var windOffset : Array;
        private var filterList : Array;
        public function Spring() {

            //情報表示用テキストフィールドを初期化
            txtFieldInit();

            //3D空間を初期化
            init3DSpace();

            //タイトル画面を初期化
            initTitleScrnBtn();
            //ランド画面を初期化
            initLandScrnBtn();
        }

        //テキストフィールドの初期化処理
        private function txtFieldInit():void{
            //テキストフィールド(ラベル)の生成
            txtField["titleScrnInfo"]=Util.makeTxtField(10,10,10,10);//タイトル画面表示用のテキストを設定
            txtField["landScrnInfo"]=Util.makeTxtField(10,10,300,40);//ランド画面表示用のテキストを設定
            //テキストフォーマットの生成
            txtFormat["titleScrnInfo"]=Util.makeTextFormat(15,0x000000);
            txtFormat["landScrnInfo"]=Util.makeTextFormat(15,0x000000);
        }
        //テキストフィールドの編集
        private function editLabel(key:String,text:String):void {
            txtField[key].text=text;
            txtField[key].setTextFormat(txtFormat[key]);        
        }

        //タイトル画面情報テキストを設定
        public function addTitleScrnTxt():void {
            addChild(txtField["titleScrnInfo"]); //タイトル画面のテキストを表示(今回は使用せず)
            editLabel("titleScrnInfo", "");
        }
        //タイトル画面情報テキストを設定解除
        public function removeTitleScrnTxt():void {
            editLabel("titleScrnInfo", "");
            removeChild(txtField["titleScrnInfo"]); //タイトル画面のテキストを非表示(今回は使用せず)
        }
        //ランド画面情報テキストを設定
        private function addLandScrnTxt():void {
            addChild(txtField["landScrnInfo"]);
            var landScrnInfoTxt : String = "床クリックで緑色→土色→桜→緑色と変化" + "\n"
                                         + "A,W,S,D,F,Rボタンで視点変更します" + "\n";
            editLabel("landScrnInfo",landScrnInfoTxt);
        }
        //ランド画面情報テキストを設定解除
        private function removeLandScrnTxt():void {
            editLabel("landScrnInfo", "");
            removeChild(txtField["landScrnInfo"]);
        }
//■■■タイトル画面ボタン初期化スタート■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
        //タイトル画面ボタンを初期化する
        public function initTitleScrnBtn():void {
            goLandScrnBtn = new CustomButton("ランド画面");
            goLandScrnBtn.x = 400;
            goLandScrnBtn.y = 280;
            goLandScrnBtn.addEventListener(MouseEvent.MOUSE_DOWN,goLandScrnBtnDown);
            addChild(goLandScrnBtn);
        }
        //タイトル画面ボタンを非表示にする
        public function hideTitleScrnBtn():void {
            goLandScrnBtn.visible = false;
        }
        //タイトル画面ボタンを表示する
        public function dispTitleScrnBtn():void {
            goLandScrnBtn.visible = true;
        }
//■■■タイトル画面ボタン初期化エンド■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
//■■■ランド画面ボタン初期化スタート■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
        //ランド画面ボタンを初期化する
        public function initLandScrnBtn():void {
            //「リセット」ボタン設定
            resetBtn = new CustomButton("リセット");
            resetBtn.x = 400;
            resetBtn.y = 0;
            resetBtn.addEventListener(MouseEvent.MOUSE_DOWN,onResetBtnDown);
            addChild(resetBtn);
            //「桜散」ボタン設定
            sakuraFallBtn = new CustomButton("桜散");
            sakuraFallBtn.x = 400;
            sakuraFallBtn.y = 30;
            sakuraFallBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSakuraFallBtnDown);
            addChild(sakuraFallBtn);
            //「夜桜」ボタン設定
            sakuraNightBtn = new CustomButton("夜桜");
            sakuraNightBtn.x = 400;
            sakuraNightBtn.y = 60;
            sakuraNightBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSakuraNightBtnDown);
            addChild(sakuraNightBtn);

            //「クエスト画面」ボタン設定
            goTitleScrnBtn = new CustomButton("タイトル画面");
            goTitleScrnBtn.x = 400;
            goTitleScrnBtn.y = 280;
            goTitleScrnBtn.addEventListener(MouseEvent.MOUSE_DOWN,goTitleScrnBtnDown);
            addChild(goTitleScrnBtn);

            forwardBtn = new CustomButton("前進");
            forwardBtn.x = 200;
            forwardBtn.y = 410;
            leftRotBtn = new CustomButton("左回転");
            leftRotBtn.x = 90;
            leftRotBtn.y = 440;
            bDashBtn = new CustomButton("Bダッシュ");
            bDashBtn.x = 200;
            bDashBtn.y = 440;
            rightRotBtn = new CustomButton("右回転");
            rightRotBtn.x = 310;
            rightRotBtn.y = 440;
            backwardBtn = new CustomButton("後退");
            backwardBtn.x = 200;
            backwardBtn.y = 470;
            forwardBtn.addEventListener(MouseEvent.MOUSE_DOWN,onForwardBtnDown);
            forwardBtn.addEventListener(MouseEvent.MOUSE_UP,onForwardBtnUp);
            forwardBtn.addEventListener(MouseEvent.MOUSE_OUT,onForwardBtnOut);
            leftRotBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLeftRotBtnDown);
            leftRotBtn.addEventListener(MouseEvent.MOUSE_UP,onLeftRotBtnUp);
            leftRotBtn.addEventListener(MouseEvent.MOUSE_OUT,onLeftRotBtnOut);
            bDashBtn.addEventListener(MouseEvent.MOUSE_DOWN,onBDashBtnDown);
            bDashBtn.addEventListener(MouseEvent.MOUSE_UP,onBDashBtnUp);
            bDashBtn.addEventListener(MouseEvent.MOUSE_OUT,onBDashBtnOut);
            rightRotBtn.addEventListener(MouseEvent.MOUSE_DOWN,onRightRotBtnDown);
            rightRotBtn.addEventListener(MouseEvent.MOUSE_UP,onRightRotBtnUp);
            rightRotBtn.addEventListener(MouseEvent.MOUSE_OUT,onRightRotBtnOut);
            backwardBtn.addEventListener(MouseEvent.MOUSE_DOWN,onBackwardBtnDown);
            backwardBtn.addEventListener(MouseEvent.MOUSE_UP,onBackwardBtnUp);
            backwardBtn.addEventListener(MouseEvent.MOUSE_OUT,onBackwardBtnOut);
            addChild(forwardBtn);
            addChild(leftRotBtn);
            addChild(bDashBtn);
            addChild(rightRotBtn);
            addChild(backwardBtn);

            //ランド画面に遷移するまでボタンを非表示
            hideLandScrnBtn();
        }
        //ランド画面ボタンを非表示
        private function hideLandScrnBtn():void {
            resetBtn.visible = false;
            sakuraFallBtn.visible = false;
            sakuraNightBtn.visible = false;
            goTitleScrnBtn.visible = false;
            forwardBtn.visible = false;
            leftRotBtn.visible = false;
            rightRotBtn.visible = false;
            backwardBtn.visible = false;
            bDashBtn.visible = false;
        }
        //ランド画面ボタンを再表示
        private function dispLandScrnBtn():void {
            resetBtn.visible = true;
            sakuraFallBtn.visible = true;
            sakuraNightBtn.visible = true;
            goTitleScrnBtn.visible = true;
            forwardBtn.visible = true;
            leftRotBtn.visible = true;
            rightRotBtn.visible = true;
            backwardBtn.visible = true;
            bDashBtn.visible = true;
        }
//■■■ランド画面ボタン初期化エンド■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
//■■■3D空間を初期化スタート■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
        //3D空間を初期化
        private function init3DSpace():void {
            //ビューポート生成
            viewport = new Viewport3D(500, 500, false, true);
            viewport.opaqueBackground = 0x0055FF;
            addChild(viewport);

            //シーン生成
            scene = new Scene3D();

            //レンダリングエンジン生成
            renderer = new BasicRenderEngine();

             //カメラ設定
            camera = new Camera3D();
            camera.y = 200;
            camera.target = DisplayObject3D.ZERO;

            //タイトル文字の設定　引数は色コード・透過度
            letterformat = new Letter3DMaterial(0xFF9999 , 0.9);
            letterformat.doubleSided = true
            title3DText = new Text3D("SPRING HanaMi" , new HelveticaBold() , letterformat);
            title3DText.y += 400;
            title3DText.scale = 1;
            Objs["title3DText"] = title3DText;
            scene.addChild(Objs["title3DText"], "title3DText");

            //最初のクエスト画面用に3Dオブジェクト初期化
            var tempBlueColorMaterial : ColorMaterial = new ColorMaterial(0x0000EE, 0.5);
            tempBlueColorMaterial.doubleSided = true;
            var tempRedColorMaterial : ColorMaterial = new ColorMaterial(0xEE0000, 0.5);
            tempRedColorMaterial.doubleSided = true;
            var tempGreenColorMaterial : ColorMaterial = new ColorMaterial(0x00EE00, 0.5);
            tempGreenColorMaterial.doubleSided = true;
            materialList.addMaterial(tempRedColorMaterial, "front");
            materialList.addMaterial(tempBlueColorMaterial, "back");
            materialList.addMaterial(tempGreenColorMaterial, "right");
            materialList.addMaterial(tempBlueColorMaterial, "left");
            materialList.addMaterial(tempRedColorMaterial, "top");
            materialList.addMaterial(tempGreenColorMaterial, "bottom");
            //飾り用3Dクリスタル表示
            crystalBoxCube = new Cube(materialList, 350, 350, 350);
            Objs["crystalBoxCube"] = crystalBoxCube;
            scene.addChild(Objs["crystalBoxCube"], "crystalBoxCube");

            //ランド画面土台Planeオブジェクト設定
            for (var xIndex:int = 0; xIndex < 10; xIndex++){
	        for (var zIndex:int = 0; zIndex < 10; zIndex++){
                    //3DPlaneオブジェクトの設定
                    material = new ColorMaterial( 0x00FF00, 1 );
	            material.doubleSided = true;
	            material.smooth = true;
	            material.interactive = true;  
                    planeObj= new Plane(material, 290, 290, 1, 1); 
	            planeObj.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, mouseClickPlane);
	            planeObj.name = "planeX" + xIndex + "_Z" + zIndex;
	            planeObj.x = (300 * xIndex);
	            planeObj.z = 300 * zIndex;
	            planeObj.rotationX += 90;
	            planeObj.name = "green";
	            //Planeオブジェクトに名前を割り振り
	            //7行3列の場合の名前例："planeX7_Z3"
	            tempPlaneName = "planeX" + xIndex + "_Z" + zIndex;
	            Objs[tempPlaneName] = planeObj;
            	}
            }

            //フィルターの準備
            filterList = new Array();
            var glowFilter : GlowFilter = new GlowFilter(0xFFFFFF, 1, 32, 32, 2, 1, false, false); 
            filterList.push(glowFilter);
            //Sphereによる月を設定
            var moonMaterial : ColorMaterial = new ColorMaterial(0xEEEE00, 0.7);
            moonSphere = new Sphere(moonMaterial, 80, 12, 9);
            moonSphere.useOwnContainer = true;
            moonSphere.filters = filterList; //フィルター使用のために設定
            moonSphere.y = 1000;
            moonSphere.x = 1350;
            moonSphere.z = 3000;
            Objs["moonSphere"] = moonSphere;

            daeNomaneko = new DAE();
            daeNomaneko.load("http://oretaikan.atukan.com/ActionScript/DaeTest/DaeTest10/nomaNeko.dae");
            daeNomaneko.scale = 50;
            Objs["daeNomaneko"] = daeNomaneko;

            //Particlesオブジェクト設定
            //生成するパーティクルの設定。色とアルファ値
            particleMat = new ParticleMaterial(0xFF9999, 1);
            //大きさ3000の立方体の中に大きさ8のパーティクルを1000個生成
            pFieldHeight = 500;
            numParticles = 1000;
            fieldSize = 3000;
            particleField = new ParticleField(particleMat, numParticles, 8, fieldSize, pFieldHeight, fieldSize);
            for( var i:int = 0; i < numParticles; i++ )
            {
                Particle(particleField.particles[i]).size = Math.random() * 10 + 1;
            }
            particleField.y = pFieldHeight / 2;
            particleField.x = 1500;
            particleField.z = 1500;
            windOffset = new Array( 3 ); //wind offset
            windOffset[0] = 3;
            windOffset[1] = 5;
            windOffset[2] = 0;

            Objs["particleMat"] = particleMat;
            Objs["particleField"] = particleField;

            //マウスイベント処理用リスナを設定
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }
//■■■イベント処理スタート■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
        //イベント処理
        private function onEnterFrame(e:Event):void{
            if (screenId == TITLE_SCREEN_ID) {
                title3DText.rotationX -= 10;
		crystalBoxCube.rotationX = viewport.mouseY; //飾り用クリスタルの座標をマウス座標から設定
		crystalBoxCube.rotationY = viewport.mouseX; //飾り用クリスタルの座標をマウス座標から設定
                setCameraForTitleScrn(); //カメラ視点設定
                renderer.renderScene(scene, camera, viewport);
            } else if (screenId == LAND_SCREEN_ID) {
                if (sakuraFallState == true) { pouringParticles(); }//桜散る動きを設定
                calcNomanekoPos(); //操作用3D「のまねこ」座標を設定
                setCameraForLandScrn(); //カメラ視点設定
                renderer.renderScene(scene, camera, viewport);
            }
        }
        //ランド画面の操作用3D「のまねこ」座標を設定
        private function calcNomanekoPos():void{
            if (forwardState == true) {//前進
                daeNomaneko.moveForward(-30);
            } else if (backwardState == true) {//後退
                daeNomaneko.moveForward(30);
            } else if (leftRotState == true) {//左回転
                daeNomaneko.rotationY -= 10;
            } else if (rightRotState == true) {//右回転
                daeNomaneko.rotationY += 10;
            } else if (bDashState == true) {//Bダッシュ
                daeNomaneko.moveForward(-60);
            }
        }
        //タイトル画面用カメラ視点設定
        private function setCameraForTitleScrn():void{
            var cameraDist : int = -1000; //デフォルトの距離、ステータスは1
            camera.x=cameraDist*Math.cos((90-crystalBoxCube.rotationY)*Math.PI/180)+crystalBoxCube.x;  
            camera.z=cameraDist*Math.sin((90-crystalBoxCube.rotationY)*Math.PI/180)+crystalBoxCube.z;
            camera.target.x=crystalBoxCube.x;
            camera.target.y=crystalBoxCube.y;
            camera.target.z=crystalBoxCube.z;
            cameraPitch = 90; //カメラのX軸回転の値　
            cameraYaw = 270; //カメラのY軸回転の値
            camera.orbit(cameraPitch, cameraYaw, true, crystalBoxCube);
        }
        //ランド画面用カメラ視点設定
        private function setCameraForLandScrn():void{
            var cameraDist : int = -1000; //デフォルトの距離、ステータスは1
            if (cameraDistStat == 0) {
                cameraDist = -500;
            } else if (cameraDistStat == 1) {
                cameraDist = -1000;
            } else if (cameraDistStat == 2) {
                cameraDist = -1500;
            }
            camera.x=cameraDist*Math.cos((90-daeNomaneko.rotationY)*Math.PI/180)+daeNomaneko.x;  
            camera.z=cameraDist*Math.sin((90-daeNomaneko.rotationY)*Math.PI/180)+daeNomaneko.z;
            camera.target.x=daeNomaneko.x;
            camera.target.y=daeNomaneko.y;
            camera.target.z=daeNomaneko.z;
            camera.orbit(cameraPitch, cameraYaw, true, daeNomaneko);
        }
        //桜散る動き
        private function pouringParticles():void
        {
            theta += Math.PI * 2 / 100;
            for( var iString:String in particleField.geometry.vertices )
            {
                var i:int = int( iString );
        	particleField.particles[i].y -= ( Particle( particleField.particles[ i ] ).size / 1.5 + windOffset[2] );
        	particleField.particles[i].x += ( Math.sin( theta + i ) * 3 + windOffset[0] );
        	particleField.particles[i].z += ( Math.cos( theta + i ) * 3 + windOffset[1] );
        	if( particleField.particles[i].y < - pFieldHeight / 2 )
                {
        	    particleField.particles[i].y = pFieldHeight;
                }
        	particleField.particles[i].x = (particleField.particles[i].x + fieldSize/2 ) % fieldSize - fieldSize/2;
        	particleField.particles[i].z = (particleField.particles[i].z + fieldSize/2 ) % fieldSize - fieldSize/2;
            }
        }
        //キーボードイベント処理(押下時処理)
        private function onKeyDown(event:KeyboardEvent):void{
            if (screenId == TITLE_SCREEN_ID) {return;} //タイトル画面の場合は何も処理を行わない
            //Aボタン　操作オブジェクトを中心にカメラを左回り回転(Y軸回転)
            //4度づつ左回り回転  
            if (event.keyCode == 65) {
                cameraYaw = cameraYaw - 4;
                if(cameraYaw < 0) {cameraYaw = 360;}
            //Dボタン　操作オブジェクトを中心にカメラを右回り回転(Y軸回転)    
            //4度づつ右回り回転
            } else if (event.keyCode == 68) {
                cameraYaw = cameraYaw + 4;
                if(cameraYaw > 360) {cameraYaw = 0;}
            //Wボタン　操作オブジェクトを中心にカメラを上下移動(X軸回転)
            } else if (event.keyCode == 87) {        
                if(cameraPitch > 50) {cameraPitch = cameraPitch - 10;}
            //Sボタン　操作オブジェクトを中心にカメラを上下移動(X軸回転)
            } else if (event.keyCode == 83) {           
                if(cameraPitch < 100) {cameraPitch = cameraPitch + 10;}
            //Fボタン　カメラと操作オブジェクトの距離を変更
            } else if (event.keyCode == 70) {
                cameraDistStat -= 1;
                if(cameraDistStat < 0) {cameraDistStat = 2;}
            //Rボタン　カメラの初期化　カメラの距離と高さを初期状態に設定＆操作矢印の真後ろに設定
            } else if (event.keyCode == 82) {
                cameraDistStat = 1;
                cameraPitch = 80; //カメラのX軸回転の値　
                //cameraYaw = 270; //カメラのY軸回転の値
                cameraYaw = 270 - daeNomaneko.rotationY;
            }
        }
        //ランド画面土台Planeオブジェクトクリック時処理　緑色→土色→土色＋桜→緑色
        private function mouseClickPlane(e:InteractiveScene3DEvent):void {
            var tempPlane : Plane = (DisplayObject3D(e.target)) as Plane;
            var tempMaterial : ColorMaterial;
            if (tempPlane.name == "green") {
                tempMaterial = new ColorMaterial( 0xFF9900, 1 );
                tempMaterial.doubleSided = true;
                tempMaterial.smooth = true;
                tempMaterial.interactive = true;  
                tempPlane.material = tempMaterial;
                tempPlane.name = "tsuchi"
            }  else if (tempPlane.name == "tsuchi") {
                tempMaterial = new ColorMaterial( 0xFF9900, 1 );
                tempMaterial.doubleSided = true;
                tempMaterial.smooth = true;
                tempMaterial.interactive = true;  
                tempPlane.material = tempMaterial;
                tempPlane.name = "sakura"
                //桜もどき3Dオブジェクト生成
                var tempCylinder : Cylinder = new Cylinder( new ColorMaterial( 0xFFEEAA, 1 ), 40, 200, 8, 8);
                tempCylinder.z -= 100
                tempCylinder.rotationX += 90;
                var tempCone : Cone = new Cone( new ColorMaterial( 0xFF9999, 1 ), 130, 200, 8, 8);
                tempCone.y -= 100
                tempCone.rotationX += 180;
                tempCylinder.addChild(tempCone);
                if (sakuraNightState == true) {//夜桜モードのときはフィルター設定
                    tempCylinder.useOwnContainer = true; //フィルター使用のために設定
                    tempCylinder.filters = filterList;
                }
                tempPlane.addChild(tempCylinder, "planeTree");
            } else { //tempPlane.name == "sakura"
                tempMaterial = new ColorMaterial( 0x00FF00, 1 );
                tempMaterial.doubleSided = true;
                tempMaterial.smooth = true;
                tempMaterial.interactive = true;  
                tempPlane.material = tempMaterial;  
                tempPlane.name = "green"
                tempPlane.removeChildByName("planeTree");
            }
            
        }
//■■■イベント処理エンド■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
//■■■3D空間を初期化エンド■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
//■■■ボタン処理スタート■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
//■■■画面遷移ボタン処理スタート■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
        //タイトル画面からランド画面に遷移
        private function goLandScrnBtnDown(evt:MouseEvent):void {
            hideTitleScrnBtn(); //タイトル画面ボタンを非表示
            dispLandScrnBtn(); //ランド画面ボタンを表示

            //3Dオブジェクト表示・非表示処理
            removeTitleScrn3DObjs();
            addLandScrn3DObjs();

            addLandScrnTxt(); //ランド画面情報テキストを設定

            //スクリーンID設定
            screenId = LAND_SCREEN_ID;

            //ランド画面用のカメラ初期設定
            cameraDistStat = 1;
            cameraPitch = 80;
        }

        //ランド画面からタイトル画面に遷移
        private function goTitleScrnBtnDown(evt:MouseEvent):void {
            hideLandScrnBtn(); //ランド画面ボタンを非表示
            dispTitleScrnBtn(); //タイトル画面ボタンを表示

            //3Dオブジェクト表示・非表示処理
            removeLandScrn3DObjs();
            addTitleScrn3DObjs();

            removeLandScrnTxt(); //ランド画面情報テキストを設定解除

            //スクリーンID設定
            screenId = TITLE_SCREEN_ID;
        }

        //タイトル画面に3Dオブジェクトをセット
        private function addTitleScrn3DObjs():void {
            scene.addChild(Objs["title3DText"], "title3DText");
            scene.addChild(Objs["crystalBoxCube"], "crystalBoxCube");
        }
        //タイトル画面に3Dオブジェクトをリリース
        private function removeTitleScrn3DObjs():void {
            scene.removeChildByName("title3DText");
            scene.removeChildByName("crystalBoxCube");
        }
        //ランド画面に3Dオブジェクトをセット
        private function addLandScrn3DObjs():void {
            for (var xIndex:int = 0; xIndex < 10; xIndex++){
	        for (var zIndex:int = 0; zIndex < 10; zIndex++){
                    //3DPlaneオブジェクトを取り出す
	            //Planeオブジェクト取り出し用の名前を作成  7行3列の場合の名前例："planeX7_Z3" 
                    tempPlaneName = "planeX" + xIndex + "_Z" + zIndex;
  	            scene.addChild(Objs[tempPlaneName], tempPlaneName);
            	}
            }
            daeNomaneko = Objs["daeNomaneko"];
            //操作「のまねこ」を初期化
            daeNomaneko.y = 180;
            daeNomaneko.x = 1350; 
            daeNomaneko.z = 1350;
            daeNomaneko.rotationY = 0;
            scene.addChild(daeNomaneko, "daeNomaneko");
        }
        //ランド画面から3Dオブジェクトをリリース
        private function removeLandScrn3DObjs():void {
            //ランドマップ配列1行分の処理
            for (var xIndex:int = 0; xIndex < 10; xIndex++){
                //配列1行分の10列のデータを処理
	        for (var zIndex:int = 0; zIndex < 10; zIndex++){
                    //3DPlaneオブジェクトをリリース
                    tempPlaneName = "planeX" + xIndex + "_Z" + zIndex;
                    scene.removeChildByName(tempPlaneName);
            	}
            }
            scene.removeChildByName("daeNomaneko");
            scene.removeChildByName("particleField");
            sakuraFallState = false;
        }
//■■■画面遷移ボタン処理エンド■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
//■■■ランド画面ボタン処理スタート(遷移ボタン以外)■■■■■■■■■■■■■■■■■■■■■■■■
        //リセット機能(ランド区画のみ初期化)
        private function onResetBtnDown(evt:MouseEvent):void {
            //ランド区画を初期化
            resetLandMap();
        }
        //リセット処理
        private function resetLandMap():void {
            var tempPlane : Plane;
            var tempMaterial : ColorMaterial;
            for (var xIndex:int = 0; xIndex < 10; xIndex++){
	        for (var zIndex:int = 0; zIndex < 10; zIndex++){
                    //リセット処理
                    tempPlaneName = "planeX" + xIndex + "_Z" + zIndex;
                    tempPlane = (scene.getChildByName(tempPlaneName)) as Plane;
                    if(tempPlane != null) {
                        tempMaterial = new ColorMaterial( 0x00FF00, 1 );
                        tempMaterial.doubleSided = true;
                        tempMaterial.smooth = true;
                        tempMaterial.interactive = true;  
                        tempPlane.material = tempMaterial;
                        if (tempPlane.name == "sakura") {
                            tempPlane.removeChildByName("planeTree");
                        }
                        tempPlane.name = "green"
                    }
                }
            }
        }
        //「桜散」機能
        private function onSakuraFallBtnDown(evt:MouseEvent):void {
            //散って(落ちて)いく桜の花に見立てたパーティクルをON・OFF
            if (sakuraFallState == false) {
                //パーティクル設定
                particleField = Objs["particleField"]
                scene.addChild(particleField, "particleField");
                sakuraFallState = true;
            } else {
                scene.removeChildByName("particleField");
                sakuraFallState = false;
            } 
        }
        //「夜桜」機能
        private function onSakuraNightBtnDown(evt:MouseEvent):void {
            //フィルターを使って夜桜を表現
            var tempPlane : Plane;
            var tempCylinder : Cylinder;
            var tempCone : Cone
            if (sakuraNightState == false) {//夜桜表現を設定する
            viewport.opaqueBackground = 0x333333;
            moonSphere = Objs["moonSphere"];
            scene.addChild(moonSphere, "moonSphere");
                for (var xIndex:int = 0; xIndex < 10; xIndex++){
	            for (var zIndex:int = 0; zIndex < 10; zIndex++){
                        //リセット処理
                        tempPlaneName = "planeX" + xIndex + "_Z" + zIndex;
                        tempPlane = (scene.getChildByName(tempPlaneName)) as Plane;
                        if(tempPlane != null) {
                            if (tempPlane.name == "sakura") {
                                tempCylinder = (tempPlane.getChildByName("planeTree")) as Cylinder;
                                if(tempCylinder != null) {
                                    tempCylinder.useOwnContainer = true; //フィルター使用のために設定
                                    tempCylinder.filters = filterList;
                                }
                            }
                        }
                    }
                }
            sakuraNightState = true;
            } else {//夜桜表現を解除する
            viewport.opaqueBackground = 0x0055FF;
            scene.removeChildByName("moonSphere");
                for (var xIndex:int = 0; xIndex < 10; xIndex++){
	            for (var zIndex:int = 0; zIndex < 10; zIndex++){
                        //リセット処理
                        tempPlaneName = "planeX" + xIndex + "_Z" + zIndex;
                        tempPlane = (scene.getChildByName(tempPlaneName)) as Plane;
                        if(tempPlane != null) {
                            if (tempPlane.name == "sakura") {
                                tempCylinder = (tempPlane.getChildByName("planeTree")) as Cylinder;
                                if(tempCylinder != null) {
                                    tempCylinder.useOwnContainer = false; //フィルター使用のための設定解除
                                    tempCylinder.filters = null;
                                }
                            }
                        }
                    }
                }
            sakuraNightState = false;
            }
        }
        //前進ボタン押下時処理設定
        private function onForwardBtnDown(evt:MouseEvent):void {
            forwardState = true;
        }
        //前進ボタンリリース時処理設定1
        private function onForwardBtnUp(evt:MouseEvent):void {
            forwardState = false;
        }
        //前進ボタンリリース時処理設定2
        private function onForwardBtnOut(evt:MouseEvent):void {
            forwardState = false;
        }
        //後退ボタン押下時処理設定
        private function onBackwardBtnDown(evt:MouseEvent):void {
            backwardState = true;
        }
        //後退ボタンリリース時処理設定1
        private function onBackwardBtnUp(evt:MouseEvent):void {
            backwardState = false;
        }
        //後退ボタンリリース時処理設定2
        private function onBackwardBtnOut(evt:MouseEvent):void {
            backwardState = false;
        }
        //左回転ボタン押下時処理設定
        private function onLeftRotBtnDown(evt:MouseEvent):void {
            leftRotState = true;
        }
        //左回転ボタンリリース時処理設定1
        private function onLeftRotBtnUp(evt:MouseEvent):void {
            leftRotState = false;
        }
        //左回転ボタンリリース時処理設定2
        private function onLeftRotBtnOut(evt:MouseEvent):void {
            leftRotState = false;
        }
        //右回転ボタン押下時処理設定
        private function onRightRotBtnDown(evt:MouseEvent):void {
            rightRotState = true;
        }
        //右回転ボタンリリース時処理設定1
        private function onRightRotBtnUp(evt:MouseEvent):void {
            rightRotState = false;
        }
        //右回転ボタンリリース時処理設定2
        private function onRightRotBtnOut(evt:MouseEvent):void {
            rightRotState = false;
        }
        //Bダッシュボタン押下時処理設定
        private function onBDashBtnDown(evt:MouseEvent):void {
            bDashState = true;
        }
        //Bダッシュボタンリリース時処理設定1
        private function onBDashBtnUp(evt:MouseEvent):void {
            bDashState = false;
        }
        //Bダッシュボタンリリース時処理設定2
        private function onBDashBtnOut(evt:MouseEvent):void {
            bDashState = false;
        }
//■■■ランド画面ボタン処理エンド(遷移ボタン以外)■■■■■■■■■■■■■■■■■■■■■■■■■
//■■■ボタン処理エンド■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
    }
}
//■■■カスタムボタンクラス■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
import flash.display.*;
import flash.system.*;
import flash.text.*;
//カスタムボタン
class CustomButton extends SimpleButton {
        private var btnName : String = "";//ボタン名
        private var btnNo : int = 0;//ボタン番号
        //コンストラクタ    
        public function CustomButton(label:String="",no:int=0) {
            btnName = label;
            btnNo = no;
            //状態
            upState = makeSprite(label,0x999999);
            overState = upState;
            downState = makeSprite(label,0x0000FF);
            hitTestState = upState;
        }
        public function getBtnName():String {
            return btnName;
        }
        public function getBtnNo():int {
            return btnNo;
        }
        //ボタン用スプライト作成
        private function makeSprite(text:String,color:uint):Sprite{
            //ボタン用ラベル作成
            var label : TextField = new TextField();
            label.text = text;
            label.autoSize = TextFieldAutoSize.CENTER;
            label.selectable = false;
            //ボタン用スプライト作成
            var sp:Sprite = new Sprite();
            sp.graphics.beginFill(color);
            sp.graphics.drawRoundRect(0, 0, 100, 20, 15);
            sp.graphics.endFill();
            sp.alpha = 0.8;            
            sp.addChild(label);
            //ラベル用フォーマット設定
            var format:TextFormat=new TextFormat();
            format.font = "Courier New";
            format.bold = true;
            format.size = 13;
            label.setTextFormat(format);
            return sp;
        }
}
//■■■ユーティリティクラス■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.AntiAliasType;
import flash.text.TextFormatAlign;
//ユーティリティ
class Util
{
    //テキストフィールドの生成
    public static function makeTxtField(posX:int,posY:int,width:int,height:int):TextField {
        var label:TextField=new TextField();
        label.selectable=false;
        label.x       =posX;
        label.y       =posY;
        label.width   =width;
        label.height  =height;
        label.antiAliasType=AntiAliasType.ADVANCED;
        return label;
    }
    //テキストフォーマットの生成
    public static function makeTextFormat(size:uint,color:uint,
        align:String=TextFormatAlign.LEFT):TextFormat {
        var format:TextFormat=new TextFormat();
        format.font ="Courier New"; // 等幅フォント
        format.size =size;  
        format.color=color;
        format.bold =true;
        format.align=align;
        return format;
    }
}