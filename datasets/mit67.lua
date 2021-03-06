local argcheck = require 'argcheck'
local tnt   = require 'torchnet'
local utils = require 'torchnet-vision.datasets.utils'
local lsplit = string.split

local mit67 = {}

mit67.__download = argcheck{
   {name='dirname', type='string', default='data/raw/mit67'},
   call =
      function(dirname)
         local urlremote = 'http://groups.csail.mit.edu/vision/LabelMe/NewImages/indoorCVPR_09.tar'
         local urltrainimages = 'http://web.mit.edu/torralba/www/TrainImages.txt'
         local urltestimages = 'http://web.mit.edu/torralba/www/TestImages.txt'
         os.execute('mkdir -p '..dirname..'; '..
           'wget '..urlremote..' -P '..dirname..'; '..
           'tar -C '..dirname..' -xf '..dirname..'/indoorCVPR_09.tar')
         os.execute('wget '..urltrainimages..' -P '..dirname)
         os.execute('wget '..urltestimages..' -P '..dirname)
         local dirimg = paths.concat(dirname,'Images')
         local classes, _ = utils.findClasses(dirimg)
         for _, class in pairs(classes) do
            print('Convert class '..class..' to jpg ')
            os.execute('mogrify -format jpg '
               ..paths.concat(dirimg, class, '*.jpg'))
            -- the extension is jpg, but img need to be converted to jpg
         end
      end
}

mit67.load = argcheck{
   {name='dirname', type='string', default='data/raw/mit67'},
   call =
      function(dirname)
         local dirimg   = paths.concat(dirname, 'Images')
         local traintxt = paths.concat(dirname, 'TrainImages.txt')
         local testtxt  = paths.concat(dirname, 'TestImages.txt')
         if not (paths.dirp(dirname)   and paths.dirp(dirimg) and
                 paths.filep(traintxt) and paths.filep(testtxt)) then
            mit67.__download(dirname)
         end
         local classes, class2target = utils.findClasses(dirimg)
         local loadSample = function(line)
            local spl = lsplit(line, '/')
            local sample  = {}
            sample.path   = line
            sample.label  = spl[#spl-1]
            sample.target = class2target[sample.label]
            return sample
         end
         local trainset = tnt.ListDataset{
            filename = traintxt,
            path     = dirimg,
            load     = loadSample
         }
         local testset = tnt.ListDataset{
            filename = testtxt,
            path     = dirimg,
            load     = loadSample
         }
         return trainset, testset, classes, class2target
      end
}

return mit67



